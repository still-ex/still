defmodule Mix.Tasks.Still.Compile do
  @moduledoc """
  Compiles your site into an output folder, which is `_site` by default.
  """
  use Mix.Task

  @shortdoc "Compiles your site"

  @config_key :compilation_task

  @doc false
  def run(_) do
    Mix.Task.run("compile")
    Mix.Task.run("app.start")

    Application.put_env(:still, @config_key, true)
    Application.put_env(:still, :url_fingerprinting, true)
    Application.put_env(:still, :dev_layout, false)

    Still.Compiler.Compile.run()
  end

  @doc false
  def config_key, do: @config_key
end
