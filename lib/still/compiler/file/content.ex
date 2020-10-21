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
    @dev_layout "priv/still/dev.slime"

    defp append_development_layout(%{variables: %{extension: ".html"}, content: content} = file) do
      %{content: content} = Still.Compiler.File.DevLayout.wrap(content)

      %{file | content: content}
    end
  end

  defp append_development_layout(file) do
    file
  end

  defp render_template(file, preprocessors) do
    preprocessors
    |> Enum.reduce(
      file,
      fn preprocessor, file ->
        preprocessor.run(file)
      end
    )
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
