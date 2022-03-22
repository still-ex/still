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
  def render(%{extension: extension} = source_file) do
    %{source_file | content: do_render(source_file), extension: extension || ".html"}
  end

  defp do_render(source_file) do
    Renderer.create(source_file)
    |> apply(:render, [])
  end
end
