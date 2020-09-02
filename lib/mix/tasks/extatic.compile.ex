defmodule Mix.Tasks.Extatic.Compile do
  use Mix.Task

  @doc false
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:extatic)

    Extatic.Compiler.Traverse.run()
  end
end
