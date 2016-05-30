defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]
  use GenServer

  # Client API #
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :registry)
  end

  def register_name(moniker, pid) do
    GenServer.call(:registry, {:register_name, moniker, pid})
  end

  def whereis_name(moniker) do
    case :ets.lookup(:registry_table, moniker) do
      [] -> :undefined
      [{^moniker, pid}] -> pid
    end
  end

  def unregister_name(moniker) do
    GenServer.cast(:registry, {:unregister_name, moniker})
  end

  # define own send, then use Kernel fully qualified name
  def send(moniker, msg) do
    case whereis_name(moniker) do
      :undefined -> {:badarg, {moniker, msg}}
      pid -> Kernel.send(pid, msg)
    end
  end

  # Server API #

  def init(nil) do
    :ets.new(:registry_table, [:set, :named_table, :protected])

    {:ok, nil}
  end

  def handle_call({:register_name, moniker, pid}, _from, nil) do
    IO.inspect moniker
    case :ets.lookup(:registry_table, moniker) do
      [] ->
        Process.monitor(pid)
        register(moniker, pid)
        {:reply, :yes, nil}
      _other ->
        {:reply, :no, nil}
    end
  end

  def handle_cast({:unregister_name, moniker}, nil) do
    deregister(moniker)
    {:noreply, nil}
  end

  def handle_info({:DOWN, _ref, _type, pid, _reason}, nil) do
    deregister(pid)
    {:noreply, nil}
  end

  def handle_info(_msg, nil) do
    {:noreply, nil}
  end

  # Helper Functions #

  defp register(moniker, pid) do
    :ets.insert(:registry_table, {moniker, pid})
  end

  defp deregister(pid) when is_pid(pid) do
    case :ets.match(:registry_table, {:_, pid}) do
      [] -> nil
      [{moniker, _pid}] -> deregister(moniker)
    end
  end

  defp deregister(moniker) do
    :ets.delete(:registry_table, moniker)
  end
end
