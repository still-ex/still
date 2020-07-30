defmodule Extatic.Compiler do
  import Extatic.Utils

  require Logger

  alias __MODULE__

  def compile() do
    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()) do
      compile_folder()
    end
  end

  defp compile_folder(folder \\ "") do
    with {:ok, files} <- File.ls(Path.join(get_input_path(), folder)),
         files <- Enum.reject(files, &String.starts_with?(&1, "_")),
         _ <- Enum.map(files, &compile_file(Path.join(folder, &1))) do
      :ok
    end
  end

  defp compile_file(file) do
    if File.dir?(Path.join(get_input_path(), file)) do
      compile_folder(file)
    else
      Compiler.File.compile(file)
    end
  end
end
