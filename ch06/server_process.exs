defmodule ServerProcess do
  def call(server, msg) do
    send(server, {:request, self(), msg})

    receive do
      {:response, response} -> response
    end
  end

  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, state) do
    receive do
      {:request, caller, msg} ->
        {response, new_state} = callback_module.process_msg(msg, state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      _ -> loop(callback_module, state)
    end
  end
end

defmodule KeyValueStore do
  # Client API #
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def get_all(server) do
    ServerProcess.call(server, :all)
  end

  def get(server, key) do
    ServerProcess.call(server, {:get, key})
  end

  def put(server, key, value) do
    ServerProcess.call(server, {:put, key, value})
  end

  # Server API #
  def init do
    %{}
  end

  def process_msg({:get, key}, state) do
    response = case Map.get(state, key, nil) do
      nil -> {:error, :unkown_key}
      value -> {:ok, value}
    end

    {response, state}
  end

  def process_msg({:put, key, value}, state) do
    new_state = Map.put(state, key, value)
    {:ok, new_state}
  end

  def process_msg(:all, state) do
    {state, state}
  end

  def process_msg(_, state) do
    {:unknown_msg, state}
  end
end
