defmodule Extatic.Compiler.Preprocessor.EEx do
  require EEx

  def render(content, variables) do
    ("<% import Extatic.Compiler.ViewHelpers %>\n" <> content)
    |> EEx.eval_string(variables)
  rescue
    e in EEx.SyntaxError ->
      raise Extatic.Compiler.Preprocessor.SyntaxError,
        message: e.message,
        line_number: e.line_number,
        column: e.column,
        line: ""
  end
end
