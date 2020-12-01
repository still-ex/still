defmodule Still.Compiler.File.Content do
  require Logger

  alias Still.Compiler.Incremental
  alias Still.SourceFile
  alias Still.Compiler.PreprocessorError

  @spec render(SourceFile.t(), any()) :: SourceFile.t()
  def render(file, preprocessors) do
    render_template(file, preprocessors)
    |> append_layout()
  end

  @spec compile(SourceFile.t(), any()) :: SourceFile.t()
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

  defp append_development_layout(%{extension: ".html", content: content} = file) do
    if Application.get_env(:still, :dev_layout, false) do
      %{content: content} = Still.Compiler.File.DevLayout.wrap(content)

      %{file | content: content}
    else
      file
    end
  end

  defp render_template(file, []) do
    file
  end

  defp render_template(file, [preprocessor | remaining_preprocessors]) do
    preprocessor.run(file)
    |> render_template(remaining_preprocessors)
  catch
    :error, %{description: description} ->
      raise PreprocessorError,
        message: description,
        preprocessor: preprocessor,
        remaining_preprocessors: remaining_preprocessors,
        source_file: file,
        stacktrace: __STACKTRACE__

    :error, e ->
      case e do
        %PreprocessorError{} ->
          raise e

        _ ->
          raise PreprocessorError,
            message: inspect(e),
            preprocessor: preprocessor,
            remaining_preprocessors: remaining_preprocessors,
            source_file: file,
            stacktrace: __STACKTRACE__
      end
  end
end
