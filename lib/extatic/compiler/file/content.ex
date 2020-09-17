defmodule Extatic.Compiler.File.Content do
  require Logger

  alias Extatic.Compiler.{
    Collections,
    Incremental
  }

  def render(file, content, preprocessors, data \\ %{}) do
    with %{content: compiled, variables: data} <-
           render_template(content, preprocessors, Map.put(data, :file_path, file)),
         compiled <- append_layout(compiled, data) do
      {:ok, compiled, data}
    end
  end

  def compile(file, content, preprocessors, data \\ %{}) do
    with {:ok, compiled, data} <- render(file, content, preprocessors, data),
         compiled <- append_development_layout(compiled, preprocessors) do
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

      defp append_development_layout(content, preprocessors) do
        last_preprocessor = preprocessors |> List.last()

        if last_preprocessor.extension() == ".html" do
          %{content: compiled} =
            Application.app_dir(:extatic, @dev_layout)
            |> File.read!()
            |> render_template([Extatic.Preprocessor.Slime], %{
              children: content,
              file_path: @dev_layout
            })

          compiled
        else
          content
        end
      end

    _ ->
      defp append_development_layout(content, _preprocessor) do
        content
      end
  end

  defp render_template(content, preprocessors, variables) do
    preprocessors
    |> Enum.reduce(
      %{content: content, variables: variables},
      fn preprocessor, %{content: content, variables: variables} ->
        preprocessor.run(content, Map.put(variables, :collections, Collections.all()))
      end
    )
  end
end
