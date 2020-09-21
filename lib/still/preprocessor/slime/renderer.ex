if Code.ensure_loaded?(Slime) do
  defmodule Still.Preprocessor.Slime.Renderer do
    use Still.Preprocessor.Renderer,
      extensions: [".slime"],
      preprocessor: Still.Preprocessor.Slime

    @impl true
    def compile(content, _variables) do
      info = [file: __ENV__.file, line: __ENV__.line]

      Slime.Renderer.precompile(content)
      |> EEx.compile_string(info)
    end

    @impl true
    def ast do
      quote do
        require EEx
        require Slime
      end
    end
  end
end
