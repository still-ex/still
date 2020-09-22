defmodule Still.Preprocessor.EEx.Renderer do
  use Still.Preprocessor.Renderer,
    extensions: [".eex"],
    preprocessor: Still.Preprocessor.EEx

  @impl true
  def compile(content, _variables) do
    info = [file: __ENV__.file, line: __ENV__.line]

    EEx.compile_string(content, info)
  end

  @impl true
  def ast do
    quote do
      require EEx
    end
  end
end
