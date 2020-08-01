defmodule Extatic.Compiler.Preprocessor.EEx do
  require EEx

  @behaviour Extatic.Compiler.Preprocessor

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

  def content_tag(tag, content, opts) do
    {data, opts} = Keyword.pop(opts, :data, [])
    attrs = Enum.map(opts, fn {attr, value} -> ~s(#{attr}="#{value}") end)

    attrs =
      data
      |> Enum.map(fn {attr, value} -> ~s(data-#{attr}="#{value}") end)
      |> Enum.concat(attrs)
      |> Enum.join(" ")

    eex = """
    <#{tag} #{attrs}>
      #{content}
    </#{tag}>
    """

    EEx.eval_string(eex, [])
  end
end
