defmodule Extatic.Compiler.Content do
  require Logger

  import Extatic.Utils

  def compile(content, preprocessor) do
    with {:ok, settings, content} <- Extatic.Compiler.Metadata.parse(content),
         compiled <- render_template(content, preprocessor),
         compiled <- append_layout(compiled, preprocessor, settings),
         compiled <- append_development_layout(compiled, preprocessor) do
      {:ok, compiled}
    end
  end

  defp append_layout(content, preprocessor, settings) do
    if Map.has_key?(settings, "layout") do
      get_input_path()
      |> Path.join(settings["layout"])
      |> File.read!()
      |> render_template(preprocessor, children: content, title: Map.get(settings, "title"))
    else
      content
    end
  end

  defp append_development_layout(content, preprocessor) do
    case Mix.env() do
      :dev ->
        Application.app_dir(:extatic, "priv/extatic/dev.slime")
        |> File.read!()
        |> render_template(preprocessor, children: content)

      _ ->
        content
    end
  end

  defp render_template(content, preprocessor, variables \\ []) do
    preprocessor.render(content, [{:collections, Extatic.Collections.all()} | variables])
  end
end
