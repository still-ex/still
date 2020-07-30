defmodule Extatic.Compiler.Folder do
  import Extatic.Utils

  alias Extatic.{Compiler, Transforms, Compiler.Preprocessor}

  def compile(folder \\ "") do
    with {:ok, files} <- File.ls(Path.join(get_input_path(), folder)),
         files <- Enum.reject(files, &String.starts_with?(&1, "_")),
         _ <- Enum.map(files, &compile_file(Path.join(folder, &1))) do
      :ok
    end
  end

  defp compile_file(file) do
    if File.dir?(Path.join(get_input_path(), file)) do
      process_folder(file)
    else
      process_file(file)
    end
  end

  defp process_folder(folder) do
    cond do
      Enum.member?(pass_through_copy(), folder) -> Transforms.PassThroughCopy.run(folder)
      true -> compile(folder)
    end
  end

  defp process_file(file) do
    ext = Path.extname(file)

    cond do
      Enum.member?(Preprocessor.supported_extensions(), ext) -> Compiler.File.compile(file)
      true -> :ok
    end
  end

  defp pass_through_copy do
    Application.get_env(:extatic, :pass_through_copy, [])
  end
end
