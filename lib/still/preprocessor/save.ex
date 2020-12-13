defmodule Still.Preprocessor.Save do
  alias Still.Preprocessor
  alias Still.Compiler.Collections

  use Preprocessor

  import Still.Utils

  require Logger

  @impl true
  def render(file = %{input_file: input_file, run_type: :compile}) do
    file = %{content: content} = file |> append_development_layout()

    with new_file_path <- get_output_path(file),
         _ <- File.mkdir_p!(Path.dirname(new_file_path)),
         :ok <- File.write(new_file_path, content),
         _ <- Collections.add(file) do
      Logger.info("Compiled #{input_file}")
      {:ok, file}
    else
      msg = {:error, :preprocessor_not_found} ->
        msg

      msg ->
        Logger.error("Failed to compile #{input_file}")
        msg
    end

    file
  end

  def render(file), do: file

  defp append_development_layout(%{extension: ".html", content: content} = file) do
    if Application.get_env(:still, :dev_layout, false) do
      %{content: content} = Still.Compiler.File.DevLayout.wrap(content)

      %{file | content: content}
    else
      file
    end
  end

  defp append_development_layout(file), do: file
end
