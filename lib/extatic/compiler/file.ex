defmodule Extatic.Compiler.File do
  require Logger

  import Extatic.Utils

  alias Extatic.Compiler

  def compile(file) do
    with {:ok, compiled, _settings} <- process(file),
         new_file_name <- String.replace(file, Path.extname(file), ".html"),
         new_file_path <- Path.join(get_output_path(), new_file_name),
         _ <- File.mkdir_p!(Path.dirname(new_file_path)),
         :ok <- File.write(new_file_path, compiled) do
      Logger.info("Compiled #{file}")
      :ok
    else
      {:error, :preprocessor_not_found} ->
        :error

      _ ->
        Logger.error("Failed to compile #{file}")
        :error
    end
  end

  def render(file, data) do
    with {:ok, compiled, settings} <- process(file, data) do
      Logger.debug("Rendered #{file}")
      {:ok, compiled, settings}
    else
      {:error, :preprocessor_not_found} ->
        Logger.error("Preprocessor not found for #{file}")
        :error

      _ ->
        Logger.error("Failed to compile #{file}")
        :error
    end
  end

  defp process(file), do: process(file, %{})

  defp process(file, data) do
    with {:ok, content} <- File.read(get_input_path(file)),
         {:ok, preprocessor} <- Compiler.Preprocessor.for(file) do
      compile_content(file, content, preprocessor, data)
    end
  end

  defp compile_content(file, content, preprocessor, data) do
    Compiler.File.Content.compile(file, content, preprocessor, data)
  rescue
    e in Compiler.Preprocessor.SyntaxError ->
      Logger.error("Syntax error in #{file}\n#{e.line_number}: #{e.line}\n#{e.message}",
        file: file,
        line: e.line_number,
        crash_reason: e.message
      )

      {:error, :syntax_error}
  end
end
