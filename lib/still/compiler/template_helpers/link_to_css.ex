defmodule Still.Compiler.TemplateHelpers.LinkToCSS do
  @moduledoc """
  Generates a `link` HTML tag to the target CSS file.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """

  alias Still.Compiler.TemplateHelpers.UrlFor

  import Still.Utils

  require Logger

  @doc """
  Generates a `link` HTML tag to the target CSS file.

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

    case compile_file(file, use_cache: true) do
      %{output_file: output_file} ->
        """
        <link rel="stylesheet" #{link_opts} href=#{UrlFor.render(output_file)} />
        """

      _ ->
        Logger.error("File process not found for #{file}")
        ""
    end
  end
end
