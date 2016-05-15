defmodule Test do
  # Public API #

  def sum([num | rest]) do
    sum(rest, num)
  end

  # Helper Functions #

  defp sum([num | rest], curr_sum) do
    sum(rest, curr_sum + num)
  end

  defp sum([], acc) do
    acc
  end
end
