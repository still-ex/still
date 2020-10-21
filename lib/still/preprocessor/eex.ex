defmodule Still.Preprocessor.EEx do
  require EEx

  alias Still.Preprocessor
  alias Still.Preprocessor.EEx.Renderer

  use Preprocessor, ext: ".html"

  @impl true
  def render(file) do
    %{file | content: do_render(file)}
  rescue
    e in EEx.SyntaxError ->
      raise Preprocessor.SyntaxError,
        message: e.message,
        line_number: e.line_number,
        column: e.column,
        line: ""
  end

  defp do_render(%{variables: variables} = file) do
    variables =
      variables
      |> Map.put(:input_file, Map.get(file, :input_file))

    Renderer.create(%{file | variables: variables})
    |> apply(:render, variables |> Map.values())
  end
end
