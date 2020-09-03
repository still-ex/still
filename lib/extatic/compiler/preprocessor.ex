defmodule Extatic.Compiler.Preprocessor do
  alias Extatic.Compiler.Preprocessor

  @supported_preprocessors %{
    ".slim" => [Preprocessor.Frontmatter, Preprocessor.Slime],
    ".slime" => [Preprocessor.Frontmatter, Preprocessor.Slime],
    ".eex" => [Preprocessor.Frontmatter, Preprocessor.EEx],
    ".css" => [Preprocessor.EEx, Preprocessor.CSSMinify]
  }

  @callback render(String.t(), map()) :: %{content: String.t(), variables: map()} | no_return()

  def for(file) do
    preprocessor = @supported_preprocessors[Path.extname(file)]

    if preprocessor do
      {:ok, preprocessor}
    else
      {:error, :preprocessor_not_found}
    end
  end

  def supported_extensions do
    Map.keys(@supported_preprocessors)
  end

  defmacro __using__(opts) do
    quote do
      @behaviour Extatic.Compiler.Preprocessor

      def run(content, variables \\ %{}) do
        result = render(content, variables)

        %{result | variables: result[:variables] |> set_extension()}
      end

      def extension do
        unquote(opts)[:ext]
      end

      if not is_nil(unquote(opts)[:ext]) do
        defp set_extension(variables = %{file_path: file_path}) do
          Map.put(variables, :extension, unquote(opts)[:ext])
        end
      end

      defp set_extension(variables), do: variables
    end
  end
end
