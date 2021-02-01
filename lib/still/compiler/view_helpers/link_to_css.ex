defmodule Still.Compiler.ViewHelpers.LinkToCSS do
  alias Still.Compiler.Incremental
  alias Still.Compiler.ViewHelpers.UrlFor

  require Logger

  @spec render(String.t(), list(any())) :: String.t()
  def render(file, opts) do
    link_opts =
      opts
      |> Enum.map(fn {k, v} ->
        "#{k}=#{v}"
      end)
      |> Enum.join(" ")

    with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
         %{output_file: output_file} <- Incremental.Node.compile(pid) do
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
