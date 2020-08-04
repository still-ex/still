defmodule Extatic.Compiler.File do
  require Logger

  import Extatic.Utils

  alias Extatic.Compiler

  def compile(file) do
    with {:ok, content} <- File.read(Path.join(get_input_path(), file)),
         {:ok, preprocessor} <- Compiler.Preprocessor.for(file),
         {:ok, compiled} <- compile_content(file, content, preprocessor),
         new_file_name <- String.replace(file, Path.extname(file), ".html"),
         new_file_path <- Path.join(get_output_path(), new_file_name),
         _ <- File.mkdir_p!(Path.dirname(new_file_path)),
         :ok <- File.write(new_file_path, compiled) do
      Logger.info("Compiled #{file}")
      :ok
    else
      {:error, :preprocessor_not_found} ->
        :ok

      _ ->
        Logger.error("Failed to compile #{file}")
        :error
    end
  end

  def render(file) do
    with {:ok, content} <- File.read(Path.join(get_input_path(), file)),
         {:ok, preprocessor} <- Compiler.Preprocessor.for(file),
         {:ok, compiled} <- compile_content(file, content, preprocessor) do
      Logger.info("Rendered #{file}")
      compiled
    else
      {:error, :preprocessor_not_found} ->
        Logger.error("Preprocessor not found for #{file}")
        ""

      _ ->
        Logger.error("Failed to compile #{file}")
        ""
    end
  end

  defp compile_content(file, content, preprocessor) do
    Compiler.Content.compile(content, preprocessor)
  rescue
    e in Compiler.Preprocessor.SyntaxError ->
      Logger.error("Syntax error in #{file}\n#{e.line_number}: #{e.line}\n#{e.message}",
        file: file,
        line: e.line_number,
        crash_reason: e.message
      )

      {:ok, :syntax_error}
  end
end
