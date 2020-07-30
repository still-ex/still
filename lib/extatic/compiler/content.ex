defmodule Extatic.Compiler.Content do
  require Logger

  import Extatic.Utils

  def compile(content) do
    with {:ok, settings, content} <- Extatic.Compiler.Metadata.parse(content),
         compiled <- render_template(content),
         compiled <- append_layout(compiled, settings),
         compiled <- append_development_layout(compiled) do
      {:ok, compiled}
    end
  end

  defp append_layout(content, settings) do
    if Map.has_key?(settings, "layout") do
      get_input_path()
      |> Path.join(settings["layout"])
      |> File.read!()
      |> render_template(children: content, title: Map.get(settings, "title"))
    else
      content
    end
  end

  defp append_development_layout(content) do
    case Mix.env() do
      :dev ->
        Application.app_dir(:extatic, "priv/extatic/dev.slime")
        |> File.read!()
        |> render_template(children: content)

      _ ->
        content
    end
  end

  defp render_template(content), do: render_template(content, [])

  defp render_template(content, variables) do
    ("- import Extatic.Compiler.ViewHelpers\n" <> content)
    |> Slime.render([{:collections, Extatic.Collections.all()} | variables])
  end
end
