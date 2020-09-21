defmodule Still.Preprocessor.CSSMinify do
  alias Still.Preprocessor

  use Preprocessor, ext: ".css"

  def render(content, variables) do
    content =
      content
      |> String.split("\n")
      |> Enum.map(&Regex.replace(~r/^ */, &1, ""))
      |> Enum.join("")

    %{content: content, variables: variables}
  end
end
