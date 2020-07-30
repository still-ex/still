defmodule Extatic.Compiler.File do
  require Logger

  import Extatic.Utils

  def compile(file) do
    with {:ok, content} <- File.read(Path.join(get_input_path(), file)),
         [frontmatter, content] <- parse_frontmatter(content),
         settings <- parse_yaml(frontmatter),
         new_file_name <- String.replace(file, Path.extname(file), ".html"),
         compiled <- Slime.render(content),
         compiled <- append_layout(compiled, settings),
         compiled <- append_development_layout(compiled),
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

  defp parse_frontmatter(content) do
    case String.split(content, ~r/\n-{3,}\n/, parts: 2) do
      [frontmatter, content] -> [frontmatter, content]
      [content] -> [nil, content]
    end
  end

  defp parse_yaml(nil), do: %{}

  defp parse_yaml(yaml) do
    case YamlElixir.read_from_string(yaml) do
      {:ok, res} ->
        res

      _ ->
        Logger.error("Failed parsing frontmatter\n#{yaml}")
        %{}
    end
  end

  defp append_layout(content, settings) do
    if Map.has_key?(settings, "layout") do
      get_input_path()
      |> Path.join(settings["layout"])
      |> File.read!()
      |> IO.inspect()
      |> Slime.render(children: content, title: Map.get(settings, "title"))
    else
      content
    end
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
