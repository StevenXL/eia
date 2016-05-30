defmodule EtsPageCache do
  use GenServer

  # Client API #

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :ets_process)
  end

  def cached(key, fun) do
    read_cache(key) || cache_and_return(key, fun)
  end

  # Server API #

  def init(nil) do
    :ets.new(:ets_table, [:set, :named_table, :protected])
    {:ok, nil}
  end

  # TODO
  def handle_call({:cache_and_return, key, fun}, _from, nil) do
    {:reply, read_cache(key) || cache_response(key, fun), nil}
  end

  # Helper Functions #
  defp read_cache(key) do
    case :ets.lookup(:ets_table, key) do
      [] -> nil
      [{^key, rest}]-> rest
    end
  end

  defp cache_response(key, fun) do
    response = fun.()
    :ets.insert(:ets_table, {key, response})
    response
  end

  defp cache_and_return(key, fun) do
    GenServer.call(:ets_process, {:cache_and_return, key, fun})
  end
end
