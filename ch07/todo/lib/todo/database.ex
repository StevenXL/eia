defmodule Todo.Database do
  use GenServer

  # Client API #
  def start(folder) do
    GenServer.start(__MODULE__, folder, name: :db)
  end

  def store(key, data) do
    GenServer.cast(:db, {:store, key, data})
  end

  def retrieve(key) do
    GenServer.call(:db, {:retrieve, key})
  end

  # Server API #

  def init(folder) when is_binary(folder) do
    File.mkdir_p(folder)
    {:ok, folder}
  end

  def handle_call({:retrieve, key}, _from, folder) do
    data = case File.read(file_name(folder, key)) do
      {:ok, contents} -> contents
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
