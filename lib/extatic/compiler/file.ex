defmodule Extatic.Compiler.File do
  require Logger

  import Extatic.Utils

  alias Extatic.Compiler

  def compile(file) do
    with {:ok, content} <- File.read(Path.join(get_input_path(), file)),
         {:ok, compiled} <- Compiler.Content.compile(content),
         new_file_name <- String.replace(file, Path.extname(file), ".html"),
         :ok <- File.write(Path.join(get_output_path(), new_file_name), compiled) do
      Logger.info("Compiled #{file}")
      :ok
    else
      _ ->
        Logger.error("Failed to compile #{file}")
    end
  rescue
    e in Slime.TemplateSyntaxError ->
      Logger.error("Syntax error in #{file}\n#{e.line_number}: #{e.line}\n#{e.message}",
        file: file,
        line: e.line_number,
        crash_reason: e.message
      )
  end
end
