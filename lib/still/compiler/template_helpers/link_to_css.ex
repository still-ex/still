defmodule Still.Compiler.TemplateHelpers.LinkToCSS do
  @moduledoc """
  Generates a `link` HTML tag to the target CSS file.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """

  alias Still.Compiler.Incremental
  alias Still.Compiler.TemplateHelpers.UrlFor

  require Logger

  @doc """
  Generates a `link` HTML tag to the target CSS file.

  All options are converted to the `attr=value` format.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """
  @spec render(String.t(), list(any())) :: String.t()
  def render(file, opts) do
    link_opts =
      opts
      |> Enum.map(fn {k, v} ->
        "#{k}=#{v}"
      end)
      |> Enum.join(" ")

    with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
         %{output_file: output_file} <- Incremental.Node.compile(pid, :dry) do
      """
      <link rel="stylesheet" #{link_opts} href=#{UrlFor.render(output_file)} />
      """
    else
      _ ->
        Logger.error("File process not found for #{file}")
        ""
    end
  end
end
