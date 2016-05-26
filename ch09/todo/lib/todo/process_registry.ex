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
    GenServer.call(:registry, {:whereis_name, moniker})
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
    {:ok, %{}}
  end

  def handle_call({:register_name, moniker, pid}, _from, registry) do
    case Map.get(registry, moniker, nil) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(registry, moniker, pid}
      moniker_taken ->
        {:reply, :no, registry}
    end
  end

  def handle_call({:whereis_name, moniker}, _from, registry) do
    {:reply, Map.get(registry, moniker, :undefined), registry}
  end

  def handle_cast({:unregister_name, moniker}, registry) do
    {:noreply, Map.delete(registry, moniker)}
  end

  # Helper Functions #
end
