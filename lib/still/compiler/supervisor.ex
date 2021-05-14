defmodule Still.Compiler.Supervisor do
  @moduledoc false

  use Supervisor

  alias Still.Compiler

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      {Registry, keys: :unique, name: Compiler.Incremental.OutputFileRegistry},
      Compiler.Collections,
      Compiler.Incremental.Registry,
      Compiler.ErrorCache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
