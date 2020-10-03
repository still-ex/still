defmodule Still.Compiler.File.Content do
  require Logger

  alias Still.Compiler.{
    PreprocessorError,
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
         ext <- find_extension(file, data, preprocessors),
         compiled <- append_development_layout(compiled, ext) do
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

  if Mix.env() == :dev do
    defp append_development_layout(content, ".html") do
      Still.Compiler.File.DevLayout.wrap(content)
    end
  end

  defp append_development_layout(content, _ext) do
    content
  end

  defp render_template(content, [], variables) do
    %{content: content, variables: variables}
  end

  defp render_template(content, [preprocessor | remaining_preprocessors], variables) do
    %{content: content, variables: variables} =
      preprocessor.run(content, Map.put(variables, :collections, Collections.all()))

    render_template(content, remaining_preprocessors, variables)
  catch
    :error, %CompileError{description: description} ->
      raise PreprocessorError,
        message: description,
        preprocessor: preprocessor,
        remaining_preprocessors: remaining_preprocessors,
        content: content,
        variables: variables,
        stacktrace: __STACKTRACE__
  end

  defp find_extension(_file, %{permalink: permalink}, _preprocessors) do
    Path.extname(permalink)
  end

  defp find_extension(file, _data, preprocessors) do
    preprocessors
    |> Enum.reduce(Path.extname(file), fn p, acc ->
      p.extension() || acc
    end)
  end
end
