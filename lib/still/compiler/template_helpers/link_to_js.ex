defmodule Still.Compiler.TemplateHelpers.LinkToJS do
  @moduledoc """
  Generates a `script` HTML tag to the target JS file.

  This file must exist and to ensure that, it **will be compiled** outside
  `Still.Compiler.CompilationStage`.
  """

  alias Still.Compiler.Incremental
  alias Still.Compiler.TemplateHelpers.UrlFor

  require Logger

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

    with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
         %{output_file: output_file} <- Incremental.Node.dry_compile(pid) do
      """
      <script #{link_opts} src=#{UrlFor.render(output_file)}></script>
      """
    else
      _ ->
        Logger.error("File process not found for #{file}")
        ""
    end
  end
end
