defmodule TodoList do
  def new, do: Map.new

  def add_entry(todo_list, entry = %{date: date, title: _}) do
    Map.update(todo_list, date, [entry], &([entry| &1]))
  end

  def entries(todo_list, date = {_, _, _}) do
    Map.get(todo_list, date, nil)
  end
end
