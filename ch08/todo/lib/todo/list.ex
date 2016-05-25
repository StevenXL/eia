defmodule Todo.List do
  defstruct auto_id: 1, entries: Map.new

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, fn(entry, todo_list) ->
      entry = Map.put(entry, :id, todo_list.auto_id)
      Todo.List.add_entry(todo_list, entry)
    end)
  end

  def add_entry(todo_list = %Todo.List{auto_id: auto_id, entries: entries}, entry = %{}) do
    entry = Map.put(entry, :id, auto_id)
    new_entries  = Map.put(entries, auto_id, entry)
    %{todo_list | entries: new_entries, auto_id: (auto_id + 1)}
  end

  def entries(%Todo.List{entries: entries}, date = {_, _, _}) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
  end

  def update_entry(todo_list = %Todo.List{entries: entries}, entry_id, update_fun) do
    case entries[entry_id] do
      nil -> todo_list

      entry ->
        old_id = entry.id
        new_entry = %{id: ^old_id} = update_fun.(entry)
        new_entries = %{entries | entry_id => new_entry}
        %{todo_list | entries: new_entries}
    end
  end

  def delete(todo_list = %Todo.List{entries: entries}, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %{todo_list | entries: new_entries}
  end
end

defmodule Todo.CSVImporter do
  def import(path) do
    read_contents(path)
    |> String.split("\n")
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&(list_to_map/1))
    |> Enum.to_list
    |> Todo.List.new
  end

  defp date_string_to_date_tuple(date) when is_binary(date) do
    date
    |> String.split("/")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({}, &Tuple.append(&2, &1))
  end

  defp list_to_map([date, title]) do
    date = date_string_to_date_tuple(date)
    %{date: date, title: title}
  end

  defp read_contents(path) do
    {:ok, contents} = File.read(path)
    contents
  end
end
