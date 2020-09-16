defmodule Extatic.Preprocessor do
  @default_preprocessors %{
    ".slim" => [__MODULE__.Frontmatter, __MODULE__.Slime],
    ".slime" => [__MODULE__.Frontmatter, __MODULE__.Slime],
    ".eex" => [__MODULE__.Frontmatter, __MODULE__.EEx],
    ".css" => [__MODULE__.EEx, __MODULE__.CSSMinify]
  }

  def for(file) do
    preprocessor = preprocessors()[Path.extname(file)]

    if preprocessor do
      {:ok, preprocessor}
    else
      {:error, :preprocessor_not_found}
    end
  end

  def supported_extensions do
    preprocessors()
    |> Map.keys()
  end

  defp preprocessors do
    Map.merge(@default_preprocessors, user_defined_preprocessors())
  end

  defp user_defined_preprocessors do
    Application.get_env(:extatic, :preprocessors, %{})
  end

  @callback render(String.t(), map()) :: %{content: String.t(), variables: map()} | no_return()

  defmacro __using__(opts) do
    quote do
      @behaviour Extatic.Preprocessor

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
