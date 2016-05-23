defmodule Todo.Server do
  use GenServer
  # Client API #

  def start do
    GenServer.start(__MODULE__, nil)
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

  # Server API #

  def init(_) do
    {:ok, Todo.List.new}
  end

  def handle_call({:entries, date}, _from, todo_list) do
    entries = Todo.List.entries(todo_list, date)

    {:reply, entries, todo_list}
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  def handle_cast({:delete, id}, todo_list) do
    {:noreply, Todo.List.delete(todo_list, id)}
  end

  def handle_cast({:update, id, fun}, todo_list) do
    {:noreply, Todo.List.update(todo_list, id, fun)}
  end
end
