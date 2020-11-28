defmodule Still.Compiler.Supervisor do
  use Supervisor

  alias Still.Compiler

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      Compiler.Collections,
      Compiler.Incremental.Registry
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
