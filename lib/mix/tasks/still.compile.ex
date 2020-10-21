defmodule Mix.Tasks.Still.Compile do
  use Mix.Task

  @doc false
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:still)

    Application.put_env(:still, :url_fingerprinting, true)
    Application.put_env(:still, :dev_layout, false)

    Still.Compiler.Traverse.run()
  end
end
