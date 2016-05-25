defmodule Todo.DatabaseWorker do
  use GenServer

  # Client API #
  def start_link(folder) do
    GenServer.start_link(__MODULE__, folder)
  end

  def store(server, key, data) do
    GenServer.cast(server, {:store, key, data})
  end

  def retrieve(server, key) do
    GenServer.call(server, {:retrieve, key})
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
end
