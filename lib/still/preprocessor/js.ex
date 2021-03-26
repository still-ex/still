defmodule Still.Preprocessor.JS do
  @moduledoc """
  Preprocessor for JavaScript files that simply bypasses the file's contents.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(file) do
    %{file | extension: ".js"}
  end
end
