defmodule Mix.Tasks.Still.Compile do
  use Mix.Task

  @doc false
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:still)

    Still.Compiler.CompilationQueue.subscribe()

    Application.put_env(:still, :url_fingerprinting, true)
    Application.put_env(:still, :dev_layout, false)

    Still.Compiler.Traverse.run()

    receive do
      :bus_empty -> :ok
    after
      :infinity -> :error
    end
  end
end
