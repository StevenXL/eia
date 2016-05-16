defmodule TodoList do
  defstruct auto_id: 1, entries: Map.new

  def new, do: %TodoList{}

  def add_entry(todo_list = %TodoList{auto_id: auto_id, entries: entries}, entry = %{}) do
    entry = Map.put(entry, :id, auto_id)
    new_entries  = Map.put(entries, auto_id, entry)
    %{todo_list | entries: new_entries, auto_id: (auto_id + 1)}
  end

  def entries(%TodoList{entries: entries}, date = {_, _, _}) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
  end

  def update_entry(todo_list = %TodoList{entries: entries}, entry_id, update_fun) do
    case entries[entry_id] do
      nil -> todo_list

      entry ->
        new_entry = update_fun.(entry)
        new_entries = %{entries | entry_id => new_entry}
        %{todo_list | entries: new_entries}
    end
  end
end
