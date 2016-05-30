defmodule Todo.Server do
  use GenServer
  # Client API #

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_entry(server, entry = %{date: _, title: _}) do
    GenServer.cast(server, {:add_entry, entry})
  end

  def entries(server, date = {_, _, _}) do
    GenServer.call(server, {:entries, date})
  end

  def delete(server, id) do
    GenServer.cast(server, {:delete, id})
  end

  def update(server, id, fun) do
    GenServer.cast(server, {:update, id, fun})
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  # Server API #

  def init(name) do
    IO.puts "Initializing the Todo.Server: #{name}"

    {:ok, {name, Todo.Database.retrieve(name) || Todo.List.new}}
  end

  def handle_call({:entries, date}, _from, state = {_, todo_list}) do
    entries = Todo.List.entries(todo_list, date)

    {:reply, entries, state}
  end

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    state = {name, Todo.List.add_entry(todo_list, entry)}
    persist(state)
    {:noreply, state}
  end

  def handle_cast({:delete, id}, {name, todo_list}) do
    state = {name, Todo.List.delete(todo_list, id)}
    persist(state)
    {:noreply, state}
  end

  def handle_cast({:update, id, fun}, {name, todo_list}) do
    state = {name, Todo.List.update(todo_list, id, fun)}
    persist(state)
    {:noreply, state}
  end

  # Helper Functions #
  defp persist({name, todo_list}) do
    Todo.Database.store(name, todo_list)
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end
end
