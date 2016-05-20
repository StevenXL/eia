defmodule Calculator do
  import Kernel, except: [div: 2]
  # Client API #
  def start do
    spawn(fn ->
      loop(0)
    end)
  end

  def add(server, val) do
    send(server, {:add, val})
  end

  def sub(server, val) do
    send(server, {:sub, val})
  end

  def mul(server, val) do
    send(server, {:mul, val})
  end

  def value(server) do
    send(server, {:val, self})
  end

  def div(server, val) do
    send(server, {:div, val})
  end

  # Server API #
  defp loop(current_val) do
    new_val = receive do
      {:add, value} -> current_val + value
      {:sub, value} -> current_val - value
      {:mul, value} -> current_val * value
      {:div, value} -> Kernel.div(current_val, value)
      {:val, caller} -> send(caller, {:cal_val, current_val})
      invalid_req ->
        IO.puts "Invalid request: #{inspect invalid_req}"
        current_val
    end

    loop(new_val)
  end
end
