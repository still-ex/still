defmodule Extatic.Compiler.Preprocessor.PassThrough do
  alias Extatic.Compiler.Preprocessor

  @behaviour Preprocessor

  @impl true
  def render(content, _), do: content

  @impl true
  def content_tag(_, _, _, _) do
    raise Preprocessor.SyntaxError,
      message: "Preprocessor does not support content tags",
      line_number: "",
      line: "",
      column: ""
  end
end
