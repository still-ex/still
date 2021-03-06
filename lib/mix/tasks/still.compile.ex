defmodule Mix.Tasks.Still.Compile do
  use Mix.Task

  @config_key :compilation_task

  @doc false
  def run(_) do
    Mix.Task.run("compile")
    Mix.Task.run("app.start")

    Still.Compiler.CompilationStage.subscribe()

    Application.put_env(:still, @config_key, true)
    Application.put_env(:still, :url_fingerprinting, true)
    Application.put_env(:still, :dev_layout, false)

    Still.Compiler.Traverse.run()

    receive do
      :bus_empty -> :ok
    after
      :infinity -> :error
    end
  end

  def config_key, do: @config_key
end
