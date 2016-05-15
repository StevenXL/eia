defmodule RecursionPractice do
  # Public API #
  def list_len(list) when is_list(list), do: do_list_len(list, 0)

  def range(from, to) when from <= to and is_number(from) and is_number(to) do
    do_range([to], from, to)
  end

  def positive(list) when is_list(list) do
    do_positive([], list)
  end

  # Helper Functions #
  defp do_list_len([], sum), do: sum
  defp do_list_len([_ | rest], sum), do: do_list_len(rest, sum + 1)

  defp do_range(cur_range, from, from), do: cur_range
  defp do_range(cur_range, from, to), do: do_range([to - 1 | cur_range], from, to - 1)

  defp do_positive(positives, []), do: Enum.reverse(positives)

  defp do_positive(positives, [head | rest]) when is_number(head) and head > 0 do
    do_positive([head | positives], rest)
  end

  defp do_positive(positives, [ _ | rest]), do: do_positive(positives, rest)
end
