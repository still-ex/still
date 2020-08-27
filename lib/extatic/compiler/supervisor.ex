defmodule Extatic.Compiler.Supervisor do
  use Supervisor

  alias Extatic.Compiler

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      Compiler.Collections,
      Compiler.Context.Registry,
      Compiler.Incremental.Registry
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
