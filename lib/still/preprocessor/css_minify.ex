defmodule Still.Preprocessor.CSSMinify do
  @moduledoc """
  Minifies a CSS file. This is a very basic minifier that simply removes
  whitespaces.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{content: content} = file) do
    content =
      content
      |> String.split("\n")
      |> Enum.map(&Regex.replace(~r/^ */, &1, ""))
      |> Enum.join("")

    %{file | content: content, extension: ".css"}
  end
end
