if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime do
    require Logger

    def render(content, variables \\ []) do
      do_render(content, variables)
    rescue
      e in Slime.TemplateSyntaxError ->
        raise Extatic.Compiler.Preprocessor.SyntaxError,
          message: e.message,
          line_number: e.line_number,
          line: e.line,
          column: e.column
    end

    defp do_render(content, variables) do
      ("- import Extatic.Compiler.ViewHelpers\n" <> content)
      |> Slime.render(variables)
    end
  end
end
