defmodule Still.Preprocessor.JS do
  @moduledoc """
  Preprocessor for JavaScript files that simply bypasses the file's contents.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def extension(_), do: ".js"

  @impl true
  def render(file) do
    file
  end
end
