defmodule Still.Preprocessor.AddLayout do
  @moduledoc """
  `Still.Preprocessor` that renders the layout of a given file and wraps it
  around the content of that same file.

  Note that this rendering happens outside `Still.Compiler.CompilationStage`.

  For this preprocessor to work, it requires a `:layout` key in the metadata,
  which can be set in the frontmatter and then added to the metadata by
  `Still.Preprocessor.Frontmatter`.
  """

  alias Still.Compiler.Incremental
  alias Still.Preprocessor

  use Preprocessor

  require Logger

  @impl true
  def render(
        %{
          content: children,
          input_file: input_file,
          dependency_chain: dependency_chain,
          metadata: %{layout: layout_file} = metadata
        } = file
      )
      when not is_nil(layout_file) do
    layout_metadata =
      metadata
      |> Map.drop([:tag, :layout, :permalink, :input_file])
      |> Map.put(:children, children)
      |> Map.put(:dependency_chain, dependency_chain)

    layout_file
    |> Incremental.Registry.get_or_create_file_process()
    |> Incremental.Node.render(layout_metadata, input_file)
    |> case do
      %{content: content} ->
        %{file | content: content}

      error ->
        raise error
    end
  end

  def render(file), do: file
end
