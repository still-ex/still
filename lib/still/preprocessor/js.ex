defmodule Still.Preprocessor.JS do
  alias Still.Preprocessor

  use Preprocessor, ext: ".js"

  def render(file) do
    file
  end
end
