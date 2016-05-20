defmodule DatabaseServer do
  # Client API #
  def start do
    spawn(fn ->
      connection = :random.uniform(1000)
      loop(connection)
    end)
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

  defp loop(connection) do
    receive do
      {:run_query, caller, query} ->
        send(caller, {:query_result, execute_query(connection, query)})
      _ -> :ok
    end

    loop(connection)
  end

  defp execute_query(connection, query) do
    :timer.sleep(2000)
    "Executed #{query} using connection #{connection}"
  end
end
