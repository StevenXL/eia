defmodule Todo.Database do
  @pool_size 3

  def start_link(folder) do
    Todo.PoolSupervisor.start_link(folder, @pool_size) # delegate to the supervisor
  end

  def store(key, data) do
    key
    |> get_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def retrieve(key) do
    key
    |> get_worker
    |> Todo.DatabaseWorker.retrieve(key)
  end

  # Helper Functions #

  defp get_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
