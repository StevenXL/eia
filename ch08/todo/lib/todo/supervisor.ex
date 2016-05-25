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
      worker(Todo.Cache, [])
    ]

    IO.inspect processes

    supervise(processes, strategy: :one_for_one)
  end
end
