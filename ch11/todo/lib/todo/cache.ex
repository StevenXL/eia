defmodule Todo.Cache do
  use GenServer

  # Client API #
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :cache)
  end

  def server_process(name) do
    case Todo.ProcessRegistry.whereis_name({:todo_server, name}) do
      :undefined -> GenServer.call(:cache, {:todo_pid, name})
      pid -> pid
    end
  end

  # Server API #
  def init(_) do
    IO.puts "Initializing the Todo.Cache server"
    {:ok, %{}}
  end

  def handle_call({:todo_pid, name}, _from, state) do
    case Map.get(state, name, nil) do
      nil ->
        {:ok, todo_pid} = Todo.ServerSupervisor.start_child(name)
        new_state = Map.put(state, name, todo_pid)
        {:reply, todo_pid, new_state}
      todo_pid -> {:reply, todo_pid, state}
    end
  end
end
