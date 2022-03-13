defmodule Still.Preprocessor.Slime do
  @moduledoc """
  Renders a Slime file. See `Still.Preprocessor.Renderer` and
  `Still.Preprocessor.EEx.Renderer`.
  """

  require Slime

  alias Still.Preprocessor
  alias Still.Preprocessor.Slime.Renderer

  use Preprocessor

  @extension ".html"

  @impl true
  def render(%{run_type: :compile_metadata} = source_file),
    do: %{source_file | extension: @extension}

  def render(source_file),
    do: %{source_file | content: do_render(source_file), extension: @extension}

  defp do_render(source_file) do
    Renderer.create(source_file)
    |> apply(:render, [])
  end
end
