defmodule Still.Preprocessor.EEx do
  require EEx

  alias Still.Preprocessor
  alias Still.Preprocessor.EEx.Renderer

  use Preprocessor, ext: ".html"

  @impl true
  def render(content, variables) do
    %{content: do_render(content, variables), variables: variables}
  rescue
    e in EEx.SyntaxError ->
      raise Preprocessor.SyntaxError,
        message: e.message,
        line_number: e.line_number,
        column: e.column,
        line: ""
  end

  defp do_render(content, variables) do
    Renderer.create(content, variables)
    |> apply(:render, variables |> Map.values())
  end
end
