defmodule Extatic.Compiler.File do
  require Logger

  import Extatic.Utils

  alias Extatic.Compiler

  def compile(file) do
    with {:ok, content} <- File.read(Path.join(get_input_path(), file)),
         preprocessor <- Compiler.Preprocessor.for(file),
         {:ok, compiled} <- Compiler.Content.compile(content, preprocessor),
         new_file_name <- String.replace(file, Path.extname(file), ".html"),
         new_file_path <- Path.join(get_output_path(), new_file_name),
         _ <- File.mkdir_p!(Path.dirname(new_file_path)),
         :ok <- File.write(new_file_path, compiled) do
      Logger.info("Compiled #{file}")
      :ok
    else
      _ ->
        Logger.error("Failed to compile #{file}")
    end
  rescue
    e in Compiler.Preprocessor.SyntaxError ->
      Logger.error("Syntax error in #{file}\n#{e.line_number}: #{e.line}\n#{e.message}",
        file: file,
        line: e.line_number,
        crash_reason: e.message
      )
  end
end
