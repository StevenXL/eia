defmodule Todo.PoolSupervisor do
  use Supervisor

  def start_link(db_folder, pool_size) do
    Supervisor.start_link(__MODULE__, {db_folder, pool_size})
  end

  # Client API #

  # Server API #

  def init({db_folder, pool_size}) do
    IO.puts "Starting Todo.PoolSupervisor"

    processes = for worker_id <- 1..pool_size do
      worker(Todo.DatabaseWorker,
       [db_folder, worker_id], # notice that these will be passed in as two arguments.
       id: {:database_worker, worker_id}) # this is used internally
    end

    supervise(processes, strategy: :one_for_one)
  end
end
