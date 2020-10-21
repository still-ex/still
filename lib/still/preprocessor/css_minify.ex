defmodule Still.Preprocessor.CSSMinify do
  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def extension(_), do: ".css"

  @impl true
  def render(%{content: content} = file) do
    content =
      content
      |> String.split("\n")
      |> Enum.map(&Regex.replace(~r/^ */, &1, ""))
      |> Enum.join("")

    %{file | content: content}
  end
end
