defmodule Still.Compiler.File.Content do
  require Logger

  alias Still.Compiler.{
    PreprocessorError,
    Collections,
    Incremental
  }

  alias Still.SourceFile

  @spec render(SourceFile.t(), any()) :: SourceFile.t()
  def render(%SourceFile{} = file, preprocessors) do
    render_template(file, preprocessors)
    |> append_layout()
  end

  @spec render(SourceFile.t(), any()) :: SourceFile.t()
  def compile(file, preprocessors) do
    render(file, preprocessors)
    |> append_development_layout()
  end

  defp append_layout(
         %{
           content: children,
           input_file: input_file,
           variables: %{layout: layout_file} = variables
         } = file
       ) do
    layout_variables =
      variables
      |> Map.drop([:tag, :layout, :permalink, :input_file])
      |> Map.put(:children, children)

    %{content: content} =
      layout_file
      |> Incremental.Registry.get_or_create_file_process()
      |> Incremental.Node.render(layout_variables, input_file)

    %SourceFile{file | content: content}
  end

  defp append_layout(file), do: file

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
