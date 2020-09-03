defmodule Extatic.Compiler.Preprocessor.CSSMinify do
  alias Extatic.Compiler.Preprocessor

  use Preprocessor, ext: ".css"

  def render(content, variables) do
    content =
      content
      |> String.split("\n")
      |> Enum.map(&Regex.replace(~r/^ */, &1, ""))
      |> Enum.join("")

    {content, variables}
  end
end
