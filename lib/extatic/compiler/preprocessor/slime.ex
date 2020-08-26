if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime do
    require Logger
    require Slime

    alias Extatic.Compiler.{
      Preprocessor,
      Preprocessor.Slime.Renderer,
      Preprocessor.Slime.ContentTag
    }

    @behaviour Preprocessor

    @impl true
    def render(content, variables \\ []) do
      do_render(content, variables)
    rescue
      e in Slime.TemplateSyntaxError ->
        raise Preprocessor.SyntaxError,
          message: e.message,
          line_number: e.line_number,
          line: e.line,
          column: e.column
    end

    @impl true
    def content_tag(tag, content, opts, variables) do
      do_content_tag(tag, content, opts, variables)
    rescue
      e in Slime.TemplateSyntaxError ->
        raise Preprocessor.SyntaxError,
          message: e.message,
          line_number: e.line_number,
          line: e.line,
          column: e.column
    end

    defp do_content_tag(tag, content, opts, variables) do
      slim = ContentTag.render(tag, content, opts)

      Renderer.create_snippet(slim, variables)
      |> apply(:render, variables |> Enum.into(%{}) |> Map.values())
    end

    defp do_render(content, variables) do
      Renderer.create(content, variables)
      |> apply(:render, variables |> Enum.into(%{}) |> Map.values())
    end
  end
end
