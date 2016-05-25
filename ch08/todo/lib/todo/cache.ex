defmodule Todo.Cache do
  use GenServer

  # Client API #
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :cache)
  end

  def server_process(cache_pid, name) do
    GenServer.call(:cache, {:todo_pid, name})
  end

  # Server API #
  def init(_) do
    Todo.Database.start("./persist")
    {:ok, %{}}
  end

  def handle_call({:todo_pid, name}, _from, state) do
    case Map.get(state, name, nil) do
      nil ->
        {:ok, todo_pid} = Todo.Server.start(name)
        new_state = Map.put(state, name, todo_pid)
        {:reply, todo_pid, new_state}
      todo_pid -> {:reply, todo_pid, state}
    end
  end

  # Helper Functions #
end
