defmodule Still.Compiler.TemplateHelpers.LinkToJS do
  @moduledoc """
  Generates a `script` HTML tag to the target JS file.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """

  alias Still.Compiler.TemplateHelpers.UrlFor
  alias Still.SourceFile

  require Logger

  import Still.Utils

  @doc """
  Generates a `script` HTML tag to the target JS file.

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
    <script #{link_opts} src=\"#{UrlFor.render(output_file)}\"></script>
    """
  end
end
