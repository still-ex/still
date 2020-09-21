defmodule Mix.Tasks.Still.Compile do
  use Mix.Task

  @doc false
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:still)

    Still.Compiler.Traverse.run()
  end
end
