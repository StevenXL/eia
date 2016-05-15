defmodule StreamPractice do
  # Public API #

  def lines_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.strip/1)
    |> Stream.map(&String.length/1)
    |> Enum.to_list
  end

  def longest_line_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.strip/1)
    |> Stream.map(&String.length/1)
    |> Enum.max
  end

  def longest_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.strip/1)
    |> Enum.max_by(&String.length/1)
  end

  def words_per_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.strip/1)
    |> Stream.map(&String.split(&1, ~r/\W/))
    |> Enum.map(&Enum.count/1)
  end

  # Helper Functions #
end
