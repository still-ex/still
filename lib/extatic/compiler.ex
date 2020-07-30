defmodule Extatic.Compiler do
  import Extatic.Utils

  require Logger

  alias __MODULE__

  def compile() do
    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()),
         {:ok, files} <- File.ls(get_input_path()),
         files <- Enum.reject(files, &String.starts_with?(&1, "_")),
         _ <- Enum.map(files, &Compiler.File.compile(&1)) do
      :ok
    end
  end
end
