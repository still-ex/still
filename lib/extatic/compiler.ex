defmodule Extatic.Compiler do
  import Extatic.Utils

  require Logger

  def compile() do
    compile(get_input_path(), get_output_path())
  end

  def compile(input) do
    compile(input, get_output_path())
  end

  def compile(input, output) do
    with input <- Path.expand(input),
         output <- Path.expand(output),
         true <- File.dir?(input),
         :ok <- File.mkdir_p(output),
         {:ok, files} <- File.ls(input),
         files <- Enum.reject(files, &String.starts_with?(&1, "_")),
         _ <- Enum.map(files, &compile_file(input, output, &1)) do
      :ok
    end
  end

  def compile_file(input, output, file) do
    with {:ok, content} <- File.read(Path.join(input, file)),
         compiled <- Slime.render(content) |> append_development_layout(),
         new_file_name <- String.replace(file, Path.extname(file), ".html"),
         :ok <- File.write(Path.join(output, new_file_name), compiled) do
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

  defp append_development_layout(content) do
    case Mix.env() do
      :dev ->
        Slime.render(
          Application.app_dir(:extatic, "priv/extatic/dev.slime") |> File.read!(),
          children: content
        )

      _ ->
        content
    end
  end
end
