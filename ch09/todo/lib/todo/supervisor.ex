defmodule Todo.Supervisor do
  use Supervisor

  # Client API #

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  # Server API #
  def init(_) do
    IO.puts "Initializing Todo.Supervisor"

    processes = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.SystemSupervisor, []),
    ]

    supervise(processes, strategy: :rest_for_one)
  end
end
