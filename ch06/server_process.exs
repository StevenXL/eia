defmodule ServerProcess do
  def call(server, msg) do
    send(server, {:call, self(), msg})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server, msg) do
    send(server, {:cast, msg})
  end

  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, state) do
    receive do
      {:call, caller, msg} ->
        {response, new_state} = callback_module.process_call(msg, state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      {:cast, msg} ->
        new_state = callback_module.process_cast(msg, state)
        loop(callback_module, new_state)
      _ -> loop(callback_module, state)
    end
  end
end

defmodule KeyValueStore do
  # Client API #
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def get_all(server) do
    ServerProcess.call(server, :all)
  end

  def get(server, key) do
    ServerProcess.call(server, {:get, key})
  end

  def put(server, key, value) do
    ServerProcess.cast(server, {:put, key, value})
  end

  # Server API #
  def init do
    %{}
  end

  def process_call({:get, key}, state) do
    response = case Map.get(state, key, nil) do
      nil -> {:error, :unkown_key}
      value -> {:ok, value}
    end

    {response, state}
  end

  def process_call(:all, state) do
    {state, state}
  end

  def process_call(_, state) do
    {:unknown_msg, state}
  end

  def process_cast({:put, key, value}, state) do
    Map.put(state, key, value)
  end
end

defmodule TodoServer do
  # Client API #

  def start do
    ServerProcess.start(TodoServer)
  end

  def add_entry(server, entry = %{date: _, title: _}) do
    ServerProcess.cast(server, {:add_entry, entry})
  end

  def entries(server, date = {_, _, _}) do
    ServerProcess.call(server, {:entries, date})
  end

  def delete(server, id) do
    ServerProcess.cast(server, {:delete, id})
  end

  def update(server, id, fun) do
    ServerProcess.cast(server, {:update, id, fun})
  end

  # Server API #

  def init do
    TodoList.new
  end

  def process_cast({:add_entry, entry}, todo_list) do
    TodoList.add_entry(todo_list, entry)
  end

  def process_cast({:delete, id}, todo_list) do
    TodoList.delete(todo_list, id)
  end

  def process_cast({:update, id, fun}, todo_list) do
    TodoList.update(todo_list, id, fun)
  end

  def process_call({:entries, date}, todo_list) do
    new_state = TodoList.entries(todo_list, date)
    {new_state, todo_list}
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: Map.new

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, fn(entry, todo_list) ->
      entry = Map.put(entry, :id, todo_list.auto_id)
      TodoList.add_entry(todo_list, entry)
    end)
  end

  def add_entry(todo_list = %TodoList{auto_id: auto_id, entries: entries}, entry = %{}) do
    entry = Map.put(entry, :id, auto_id)
    new_entries  = Map.put(entries, auto_id, entry)
    %{todo_list | entries: new_entries, auto_id: (auto_id + 1)}
  end

  def entries(%TodoList{entries: entries}, date = {_, _, _}) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
  end

  def update_entry(todo_list = %TodoList{entries: entries}, entry_id, update_fun) do
    case entries[entry_id] do
      nil -> todo_list

      entry ->
        old_id = entry.id
        new_entry = %{id: ^old_id} = update_fun.(entry)
        new_entries = %{entries | entry_id => new_entry}
        %{todo_list | entries: new_entries}
    end
  end

  def delete(todo_list = %TodoList{entries: entries}, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %{todo_list | entries: new_entries}
  end
end

defmodule TodoList.CsvImporter do
  def import(path) do
    read_contents(path)
    |> String.split("\n")
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&(list_to_map/1))
    |> Enum.to_list
    |> TodoList.new
  end

  defp date_string_to_date_tuple(date) when is_binary(date) do
    date
    |> String.split("/")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({}, &Tuple.append(&2, &1))
  end

  defp list_to_map([date, title]) do
    date = date_string_to_date_tuple(date)
    %{date: date, title: title}
  end

  defp read_contents(path) do
    {:ok, contents} = File.read(path)
    contents
  end
end
