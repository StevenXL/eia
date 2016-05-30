defmodule Todo.SystemSupervisor do
  use Supervisor

  # Client API #

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  # Server API #

  def init(_) do
    processes = [
      worker(Todo.Cache, []),
      supervisor(Todo.Database, ["./persist"]),
      supervisor(Todo.ServerSupervisor, [])
    ]

    supervise(processes, strategy: :one_for_one)
  end
end
