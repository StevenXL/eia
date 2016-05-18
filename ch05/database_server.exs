defmodule DatabaseServer do
  # Client API #
  def start do
    spawn(&loop/0)
  end

  def run_async(server, query) do
    send(server, {:run_query, self(), query})
  end

  def get_query_result do
    receive do
      {:query_result, query_result} -> query_result
    after 5000 ->
      {:error, "Query did not complete in time"}
    end
  end

  # Server API #

  defp loop do
    receive do
      {:run_query, caller, query} -> send(caller, {:query_result, execute_query(query)})
      _ -> :ok
    end

    loop
  end

  defp execute_query(query) do
    :timer.sleep(2000)
    "Query #{query} ran"
  end
end
