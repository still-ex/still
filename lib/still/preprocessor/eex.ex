defmodule Still.Preprocessor.EEx do
  require EEx

  alias Still.Preprocessor
  alias Still.Preprocessor.EEx.Renderer

  use Preprocessor

  @impl true
  def extension(_), do: ".html"

  @impl true
  def render(file) do
    %{file | content: do_render(file)}
  end

  defp do_render(%{variables: variables} = file) do
    variables =
      variables
      |> Map.put(:input_file, Map.get(file, :input_file))

    Renderer.create(%{file | variables: variables})
    |> apply(:render, [])
  end
end
