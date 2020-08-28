defmodule Extatic.Compiler.File.Content do
  require Logger

  alias Extatic.Compiler.{
    Collections,
    Incremental,
    Preprocessor,
    File.Frontmatter
  }

  def render(file, content, preprocessor, data \\ %{}) do
    with {:ok, template_data, content} <- Frontmatter.parse(content),
         data <- Map.merge(template_data, data) |> Map.put(:file_path, file),
         compiled <- render_template(content, preprocessor, data),
         compiled <- append_layout(compiled, data) do
      {:ok, compiled, data}
    end
  end

  def compile(file, content, preprocessor, data \\ %{}) do
    with {:ok, compiled, data} <- render(file, content, preprocessor, data),
         compiled <- append_development_layout(compiled, preprocessor) do
      {:ok, compiled, data}
    end
  end

  defp append_layout(children, data = %{layout: _layout}) do
    with layout_data <-
           data
           |> Map.drop([:tag, :layout, :permalink, :file_path])
           |> Map.put(:children, children),
         {:ok, compiled, _} <-
           data[:layout]
           |> Incremental.Registry.get_or_create_file_process()
           |> Incremental.Node.render(layout_data, data[:file_path]) do
      compiled
    end
  end

  defp append_layout(children, _), do: children

  case Mix.env() do
    :dev ->
      @dev_layout "priv/extatic/dev.slime"
      @preprocessors_with_development_layout [Preprocessor.Slime]

      defp append_development_layout(content, preprocessor)
           when preprocessor in @preprocessors_with_development_layout do
        Application.app_dir(:extatic, @dev_layout)
        |> File.read!()
        |> render_template(preprocessor,
          children: content,
          file_path: @dev_layout
        )
      end

      defp append_development_layout(content, _preprocessor) do
        content
      end

    _ ->
      defp append_development_layout(content, _preprocessor) do
        content
      end
  end

  defp render_template(content, preprocessor, variables) when is_map(variables) do
    render_template(content, preprocessor, variables |> Enum.to_list())
  end

  defp render_template(content, preprocessor, variables) do
    preprocessor.render(content, [{:collections, Collections.all()} | variables])
  end
end
