defmodule Extatic.Compiler.File.Content do
  require Logger

  alias Extatic.FileProcess
  alias Extatic.Compiler.File.Frontmatter

  @dev_layout "priv/extatic/dev.slime"

  def compile(file, content, preprocessor, data \\ %{}) do
    with {:ok, template_data, content} <- Frontmatter.parse(content),
         data <- Map.merge(template_data, data) |> Map.put(:file_path, file),
         compiled <- render_template(content, preprocessor, data),
         compiled <- append_layout(compiled, data),
         compiled <- append_development_layout(compiled, preprocessor) do
      {:ok, compiled, data}
    end
  end

  defp append_layout(children, data) do
    if Map.has_key?(data, :layout) do
      layout_data =
        data
        |> Map.drop([:tag, :layout, :permalink, :file_path])
        |> Map.merge(%{children: children})

      {:ok, compiled, _} =
        data[:layout]
        |> Extatic.FileRegistry.get_or_create_file_process()
        |> FileProcess.render(layout_data, data[:file_path])

      compiled
    else
      children
    end
  end

  defp append_development_layout(content, preprocessor) do
    case Mix.env() do
      :dev ->
        Application.app_dir(:extatic, @dev_layout)
        |> File.read!()
        |> render_template(preprocessor,
          children: content,
          file_path: @dev_layout
        )

      _ ->
        content
    end
  end

  defp render_template(content, preprocessor, variables) when is_map(variables) do
    render_template(content, preprocessor, variables |> Enum.to_list())
  end

  defp render_template(content, preprocessor, variables) do
    preprocessor.render(content, [{:collections, Extatic.Collections.all()} | variables])
  end
end
