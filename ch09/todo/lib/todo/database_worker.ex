defmodule Todo.DatabaseWorker do
  use GenServer

  # Client API #
  def start_link(folder, worker_id) do
    IO.puts "Initializing the Todo.DatabaseWorker: #{worker_id}"

    GenServer.start_link(__MODULE__, folder, name: via_tuple(worker_id))
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def retrieve(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:retrieve, key})
  end

  # Server API #

  def init(folder) when is_binary(folder) do
    IO.puts "Initializing the Todo.DatabaseWorker"

    {:ok, folder}
  end

  def handle_call({:retrieve, key}, _from, folder) do
    data = case File.read(file_name(folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, folder}
  end

  def handle_cast({:store, key, data}, folder) do
    file_name(folder, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, folder}
  end

  # Helper Functions #
  defp file_name(folder, key) do
    "#{folder}/#{key}"
  end

  defp via_tuple(worker_id) do
    {:via, Todo.ProcessRegistry, {:database_worker, worker_id}}
  end
end
