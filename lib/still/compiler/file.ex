defmodule Still.Compiler.File do
  require Logger

  import Still.Utils

  alias Still.{Compiler, Preprocessor}

  def compile(file) do
    with {:ok, compiled, settings} <- compile_file(file),
         new_file_name <- get_output_file_name(file, settings),
         new_file_path <- get_output_path(new_file_name),
         _ <- File.mkdir_p!(Path.dirname(new_file_path)),
         :ok <- File.write(new_file_path, compiled) do
      Logger.info("Compiled #{file}")
      :ok
    else
      msg = {:error, :preprocessor_not_found} ->
        msg

      msg ->
        Logger.error("Failed to compile #{file}")
        msg
    end
  end

  def render(file, data) do
    with {:ok, compiled, settings} <- render_file(file, data) do
      Logger.debug("Rendered #{file}")
      {:ok, compiled, settings}
    else
      msg = {:error, :preprocessor_not_found} ->
        Logger.error("Preprocessor not found for #{file}")
        msg

      msg ->
        Logger.error("Failed to compile #{file}")
        msg
    end
  end

  defp compile_file(file) do
    with {:ok, content} <- File.read(get_input_path(file)),
         {:ok, preprocessor} <- Preprocessor.for(file) do
      compile_content(file, content, preprocessor)
    end
  end

  defp render_file(file, data) do
    with {:ok, content} <- File.read(get_input_path(file)),
         {:ok, preprocessor} <- Preprocessor.for(file) do
      render_content(file, content, preprocessor, data)
    end
  end

  defp compile_content(file, content, preprocessor) do
    Compiler.File.Content.compile(file, content, preprocessor)
  rescue
    e in Preprocessor.SyntaxError ->
      handle_syntax_error(file, e)
  end

  defp render_content(file, content, preprocessor, data) do
    Compiler.File.Content.render(file, content, preprocessor, data)
  rescue
    e in Preprocessor.SyntaxError ->
      handle_syntax_error(file, e)
  end

  def get_output_file_name(_file, %{permalink: permalink}) do
    permalink
  end

  def get_output_file_name(file, %{extension: extension}) do
    String.replace(file, Path.extname(file), extension)
  end

  def get_output_file_name(file, _), do: file

  defp handle_syntax_error(file, e) do
    Logger.error("Syntax error in #{file}\n#{e.line_number}: #{e.line}\n#{e.message}",
      file: file,
      line: e.line_number,
      crash_reason: e.message
    )

    {:error, :syntax_error}
  end
end
