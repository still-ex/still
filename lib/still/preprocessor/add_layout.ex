defmodule Still.Preprocessor.AddLayout do
  alias Still.Preprocessor
  alias Still.Compiler.Incremental

  use Preprocessor

  require Logger

  @impl true
  def render(
        %{
          content: children,
          input_file: input_file,
          metadata: %{layout: layout_file} = metadata
        } = file
      )
      when not is_nil(layout_file) do
    layout_metadata =
      metadata
      |> Map.drop([:tag, :layout, :permalink, :input_file])
      |> Map.put(:children, children)

    %{content: content} =
      layout_file
      |> Incremental.Registry.get_or_create_file_process()
      |> Incremental.Node.render(layout_metadata, input_file)

    %{file | content: content}
  end

  def render(file), do: file
end
