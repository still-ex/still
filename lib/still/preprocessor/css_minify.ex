defmodule Still.Preprocessor.CSSMinify do
  @moduledoc """
  Minifies a CSS file. This is a very basic minifier that simply removes
  whitespaces.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{content: content, run_type: :compile} = source_file) do
    content =
      content
      |> String.split("\n")
      |> Enum.map(&Regex.replace(~r/^ */, &1, ""))
      |> Enum.join("")

    %{source_file | content: content, extension: ".css"}
  end

  def render(source_file),
    do: %{source_file | extension: ".css"}
end
