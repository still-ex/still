defmodule Still.Preprocessor do
  alias Still.SourceFile

  @default_preprocessors %{
    ".slim" => [__MODULE__.Frontmatter, __MODULE__.Slime],
    ".slime" => [__MODULE__.Frontmatter, __MODULE__.Slime],
    ".eex" => [__MODULE__.Frontmatter, __MODULE__.EEx],
    ".css" => [__MODULE__.EEx, __MODULE__.CSSMinify],
    ".js" => [__MODULE__.EEx, __MODULE__.JS],
    ".md" => [__MODULE__.Frontmatter, __MODULE__.EEx, __MODULE__.Markdown]
  }

  def for(%SourceFile{input_file: file}), do: __MODULE__.for(file)

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
    Application.get_env(:still, :preprocessors, %{})
  end

  @callback render(SourceFile.t()) :: SourceFile.t() | no_return()

  defmacro __using__(opts) do
    quote do
      @behaviour Still.Preprocessor

      def run(file) do
        file
        |> set_extension()
        |> render()
      end

      def extension do
        unquote(opts)[:ext]
      end

      if not is_nil(unquote(opts)[:ext]) do
        defp set_extension(file) do
          file |> Map.put(:extension, unquote(opts)[:ext])
        end
      else
        defp set_extension(file), do: file
      end
    end
  end
end
