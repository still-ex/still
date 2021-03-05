defmodule Still.Preprocessor.EEx.Renderer do
  @moduledoc """
  `Still.Preprocessor.Renderer` implementation for EEx files.
  """

  use Still.Preprocessor.Renderer,
    extensions: [".eex"],
    preprocessor: Still.Preprocessor.EEx

  @impl true
  def compile(content) do
    EEx.compile_string(content, file: __ENV__.file, line: __ENV__.line)
  end

  @impl true
  def ast do
    quote do
      require EEx
    end
  end
end
