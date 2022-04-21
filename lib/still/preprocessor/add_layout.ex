defmodule Still.Preprocessor.AddLayout do
  @moduledoc """
  `Still.Preprocessor` that renders the layout of a given file and wraps it
  around the content of that same file.

  Note that this rendering happens outside `Still.Compiler.CompilationStage`.

  For this preprocessor to work, it requires a `:layout` key in the metadata,
  which can be set in the frontmatter and then added to the metadata by
  `Still.Preprocessor.Frontmatter`.
  """

  alias Still.Preprocessor
  alias Still.SourceFile

  use Preprocessor

  import Still.Utils

  require Logger

  @impl true
  def render(
        %SourceFile{
          content: children,
          extension: extension,
          dependency_chain: dependency_chain,
          metadata: %{layout: layout_file} = metadata,
          output_file: output_file
        } = file
      )
      when not is_nil(layout_file) do
    layout_metadata =
      metadata
      |> Map.drop([:tag, :layout, :permalink, :pagination])
      |> Map.put(:children, children)
      |> Map.put(:dependency_chain, dependency_chain)
      |> Map.put(:output_file, output_file)

    layout_file
    |> render_file(layout_metadata)
    |> SourceFile.for_extension(extension)
    |> case do
      %{content: content} ->
        %{file | content: content}

      error ->
        raise error
    end
  end

  def render(file), do: file
end
