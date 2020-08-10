defmodule Extatic.Compiler.Traverse do
  import Extatic.Utils

  alias Extatic.{FileRegistry, FileProcess}

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
    FileRegistry.get_or_create_file_process(folder)
    |> FileProcess.compile()
    |> case do
      :ok -> :ok
      _ -> run(folder)
    end
  end

  defp process_file(file) do
    FileRegistry.get_or_create_file_process(file)
    |> FileProcess.compile()
  end
end
