defmodule Still.Preprocessor.JS do
  alias Still.Preprocessor

  use Preprocessor, ext: ".js"

  def render(content, variables) do
    %{content: content, variables: variables}
  end
end
