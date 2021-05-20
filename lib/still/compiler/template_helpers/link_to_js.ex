defmodule Still.Compiler.TemplateHelpers.LinkToJS do
  @moduledoc """
  Generates a `script` HTML tag to the target JS file.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """

  alias Still.Compiler.TemplateHelpers.UrlFor

  require Logger

  import Still.Utils

  @doc """
  Generates a `script` HTML tag to the target JS file.

  All options are converted to the `attr=value` format.
  """

  @spec render(String.t(), list(any())) :: String.t()
  def render(file, opts) do
    link_opts =
      opts
      |> Enum.map(fn {k, v} ->
        "#{k}=#{v}"
      end)
      |> Enum.join(" ")

    case dry_compile_file(file) do
      %{output_file: output_file} ->
        """
        <script #{link_opts} src=#{UrlFor.render(output_file)}></script>
        """

      _ ->
        Logger.error("File process not found for #{file}")
        ""
    end
  end
end
