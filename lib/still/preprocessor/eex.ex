defmodule Still.Preprocessor.EEx do
  @moduledoc """
  Renders an EEx file. See `Still.Preprocessor.Renderer` and
  `Still.Preprocessor.EEx.Renderer`.
  """

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

  defp do_render(%{metadata: metadata} = file) do
    metadata =
      metadata
      |> Map.put(:input_file, Map.get(file, :input_file))

    Renderer.create(%{file | metadata: metadata})
    |> apply(:render, [])
  end
end
