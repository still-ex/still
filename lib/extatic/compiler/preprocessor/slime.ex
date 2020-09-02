if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime do
    require Slime

    alias Extatic.Compiler.{
      Preprocessor,
      Preprocessor.Slime.Renderer
    }

    @behaviour Preprocessor

    @impl true
    def extension() do
      ".html"
    end

    @impl true
    def render(content, variables \\ %{}) do
      {do_render(content, variables), variables}
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
end
