defmodule Still.Preprocessor.CSSMinify do
  alias Still.Preprocessor

  use Preprocessor, ext: ".css"

  def render(%{content: content} = file) do
    content =
      content
      |> String.split("\n")
      |> Enum.map(&Regex.replace(~r/^ */, &1, ""))
      |> Enum.join("")

    %{file | content: content}
  end
end
