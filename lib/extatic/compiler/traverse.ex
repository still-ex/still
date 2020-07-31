defmodule Extatic.Compiler.Traverse do
  import Extatic.Utils

  alias Extatic.Compiler

  def run(folder \\ "") do
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
    with :ok <- Compiler.PassThroughCopy.try(folder) do
      :ok
    else
      _ -> run(folder)
    end
  end

  defp process_file(file) do
    with :ok <- Compiler.PassThroughCopy.try(file) do
      :ok
    else
      _ -> Compiler.File.compile(file)
    end
  end
end
