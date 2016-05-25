defmodule Todo.Database do
  use GenServer

  # Client API #
  def start_link(folder) do
    GenServer.start_link(__MODULE__, folder, name: :db)
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

  # Server API #

  def init(folder) when is_binary(folder) do
    IO.puts "Initializing the Todo.Database"

    {:ok, start_workers(folder)}
  end

  def handle_call({:get_worker, key}, _from, workers) do
    worker = Enum.at(workers, :erlang.phash2(key, 3))
    {:reply, worker, workers}
  end

  # Helper Functions #

  defp get_worker(key) do
    GenServer.call(:db, {:get_worker, key})
  end

  defp start_workers(folder) when is_binary(folder) do
    1..3
    |> Enum.map(fn(_) ->
      {:ok, pid} = Todo.DatabaseWorker.start_link(folder)
      pid
    end)
  end
end
