defmodule Extatic.Compiler do
  import Extatic.Utils

  require Logger

  alias __MODULE__

  def compile() do
    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()) do
      Extatic.Collections.reset()
      collect_metadata()
      __MODULE__.Traverse.run()
    end
  end

  defp collect_metadata(folder \\ "") do
    with {:ok, files} <- File.ls(Path.join(get_input_path(), folder)),
         files <- Enum.reject(files, &String.starts_with?(&1, "_")),
         _ <- Enum.map(files, &collect_file_metadata(Path.join(folder, &1))) do
      :ok
    end
  end

  defp collect_file_metadata(file) do
    if File.dir?(Path.join(get_input_path(), file)) do
      collect_metadata(file)
    else
      {:ok, metadata, _content} =
        file
        |> get_input_path()
        |> File.read!()
        |> Compiler.File.Frontmatter.parse()

      handle_metadata(file, metadata)
    end
  end

  def handle_metadata(file, metadata = %{tag: tag}) when not is_nil(tag) do
    Extatic.Collections.add(tag, Map.put(metadata, "id", file))
  end

  def handle_metadata(_file, _metadata), do: :ok
end
