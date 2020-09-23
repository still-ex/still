defmodule Still.Preprocessor.Slime do
  require Slime

  alias Still.Preprocessor
  alias Still.Preprocessor.Slime.Renderer

  use Preprocessor, ext: ".html"

  @impl true
  def render(content, variables) do
    %{content: do_render(content, variables), variables: variables}
  rescue
    e in Slime.TemplateSyntaxError ->
      raise Preprocessor.SyntaxError,
        message: e.message,
        line_number: e.line_number,
        line: e.line,
        column: e.column
  end

  defp do_render(content, variables) do
    Renderer.create(content, variables)
    |> apply(:render, variables |> Map.values())
  end
end
