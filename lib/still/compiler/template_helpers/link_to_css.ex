defmodule Still.Compiler.TemplateHelpers.LinkToCSS do
  @moduledoc """
  Generates a `link` HTML tag to the target CSS file.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """

  alias Still.SourceFile
  alias Still.Compiler.TemplateHelpers.UrlFor

  import Still.Utils

  require Logger

  @doc """
  Generates a `link` HTML tag to the target CSS file.

  All options are converted to the `attr=value` format.
  """
  @spec render(map(), String.t(), list(any())) :: String.t()
  def render(env, input_file, opts) do
    link_opts =
      opts
      |> Enum.map(fn {k, v} ->
        "#{k}=#{v}"
      end)
      |> Enum.join(" ")

    %{output_file: output_file} =
      input_file
      |> compile_file(use_cache: true)
      |> SourceFile.for_extension(env.extension)

    """
    <link rel="stylesheet" #{link_opts} href=\"#{UrlFor.render(output_file)}\" />
    """
  end
end
