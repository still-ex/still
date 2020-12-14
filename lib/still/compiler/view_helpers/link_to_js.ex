defmodule Still.Compiler.ViewHelpers.LinkToJS do
  alias Still.Compiler.Incremental
  alias Still.Compiler.ViewHelpers.UrlFor

  require Logger

  def render(file, opts, env) do
    link_opts =
      opts
      |> Enum.map(fn {k, v} ->
        "#{k}=#{v}"
      end)
      |> Enum.join(" ")

    with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
         %{output_file: output_file} <- Incremental.Node.render(pid, %{}) do
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
