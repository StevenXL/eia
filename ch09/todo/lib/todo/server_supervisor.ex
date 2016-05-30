defmodule Todo.ServerSupervisor do
  use Supervisor

  # Client API #
  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :todo_server_sup)
  end

  def start_child(name) do
    Supervisor.start_child(:todo_server_sup, [name]) # notice use of list, will be merged with child spec in init function
  end

  # Server API #

  def init(_) do
    IO.puts "Starting Todo.ServerSupervisor"

    processes = [
      worker(Todo.Server, [])
    ]

    supervise(processes, strategy: :simple_one_for_one)
  end
end
