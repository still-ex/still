if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime do
    require Logger

    @behaviour Extatic.Compiler.Preprocessor

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

    def content_tag(tag, content, opts) do
      {data, opts} = Keyword.pop(opts, :data, [])
      attrs = Enum.map(opts, fn {attr, value} -> ~s(#{attr}="#{value}") end)

      attrs =
        data
        |> Enum.map(fn {attr, value} -> ~s(data-#{attr}="#{value}") end)
        |> Enum.concat(attrs)
        |> Enum.join(" ")

      slim = """
      #{tag} #{attrs}
        | #{content}
      """

      Slime.render(slim)
    end

    defp do_render(content, variables) do
      ("- import Extatic.Compiler.ViewHelpers\n" <> content)
      |> Slime.render(variables)
    end
  end
end
