defmodule Still.Compiler.File do
  require Logger

  import Still.Utils

  alias Still.{Compiler, Preprocessor, Compiler.Collections, SourceFile}

  def compile(input_file) do
    %SourceFile{content: content} =
      file =
      %SourceFile{input_file: input_file}
      |> compile_file()
      |> set_output_file()

    with new_file_path <- get_output_path(file),
         _ <- File.mkdir_p!(Path.dirname(new_file_path)),
         :ok <- File.write(new_file_path, content),
         _ <- Collections.add(file) do
      Logger.info("Compiled #{input_file}")
      :ok
    else
      msg = {:error, :preprocessor_not_found} ->
        msg

      msg ->
        Logger.error("Failed to compile #{input_file}")
        msg
    end
  end

  def render(input_file, variables) do
    file = %SourceFile{input_file: input_file, variables: variables}

    with %SourceFile{} = file <- render_file(file) do
      Logger.debug("Rendered #{input_file}")
      file
    else
      msg = {:error, :preprocessor_not_found} ->
        Logger.error("Preprocessor not found for #{input_file}")
        msg

      msg ->
        Logger.error("Failed to compile #{input_file}")
        msg
    end
  end

  defp compile_file(file) do
    with {:ok, content} <- File.read(get_input_path(file)),
         file <- %SourceFile{file | content: content},
         {:ok, preprocessor} <- Preprocessor.for(file) do
      compile_content(file, preprocessor)
    end
  end

  defp render_file(file) do
    with {:ok, content} <- File.read(get_input_path(file)),
         file <- %SourceFile{file | content: content},
         {:ok, preprocessor} <- Preprocessor.for(file) do
      render_content(file, preprocessor)
    end
  end

  defp compile_content(file, preprocessor) do
    Compiler.File.Content.compile(file, preprocessor)
  rescue
    e in Preprocessor.SyntaxError ->
      handle_syntax_error(file, e)
  end

  defp render_content(file, preprocessor) do
    Compiler.File.Content.render(file, preprocessor)
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
