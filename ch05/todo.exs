defmodule TodoServer do
  # Client API #
  def start do
    spawn(fn() ->
      loop(TodoList.new)
    end)
  end

  def add_entry(server, entry = %{date: {_, _, _}, title: _}) do
    send(server, {:add_entry, entry})
  end

  def entries(server, date = {_, _, _}) do
    send(server, {:entries, self(), date})
    receive do
      {:entries, entries} -> entries
    end
  end

  # Server API #
  defp loop(state) do
    new_state = receive do
      {:add_entry, entry = %{}} -> TodoList.add_entry(state, entry)
      {:delete, entry_id} -> TodoList.delete(state, entry_id)
      {:update_entry, entry_id, update_fun} -> TodoList.update_entry(state, entry_id, update_fun)
      {:entries, caller, date = {_, _, _}} ->
        entries = TodoList.entries(state, date)
        send(caller, {:entries, entries})
        state
      invalid ->
        IO.puts "Invalid Msg Received: #{inspect invalid}"
    end

    loop(new_state)
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
