defmodule Todo.Cache do
  use GenServer

  # Client API #
  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, name) do
    GenServer.call(cache_pid, {:todo_pid, name})
  end

  # Server API #
  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:todo_pid, name}, _from, state) do
    case Map.get(state, name, nil) do
      nil ->
        {:ok, todo_pid} = Todo.Server.start()
        new_state = Map.put(state, name, todo_pid)
        {:reply, todo_pid, new_state}
      todo_pid -> {:reply, todo_pid, state}
    end
  end

  # Helper Functions #
end
