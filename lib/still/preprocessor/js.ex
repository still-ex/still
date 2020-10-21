defmodule Still.Preprocessor.JS do
  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def extension(_), do: ".js"

  @impl true
  def render(file) do
    file
  end
end
