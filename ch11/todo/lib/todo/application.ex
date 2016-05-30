defmodule Todo.Application do
  use Application

  def start(_type, _args) do
    Todo.Supervisor.start_link
  end
end
