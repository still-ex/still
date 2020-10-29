defmodule Still.Preprocessor do
  alias Still.SourceFile

  alias __MODULE__.{
    CSSMinify,
    EEx,
    Frontmatter,
    JS,
    Markdown,
    OutputPath,
    OutputPath,
    Slime,
    URLFingerprinting
  }

  @default_preprocessors %{
    ".slim" => [Frontmatter, Slime, OutputPath],
    ".slime" => [Frontmatter, Slime, OutputPath],
    ".eex" => [Frontmatter, EEx, OutputPath],
    ".css" => [EEx, CSSMinify, OutputPath, URLFingerprinting],
    ".js" => [EEx, JS, OutputPath, URLFingerprinting],
    ".md" => [Frontmatter, EEx, Markdown, OutputPath]
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

  @callback render(SourceFile.t()) :: SourceFile.t()
  @callback extension(SourceFile.t()) :: String.t()
  @optional_callbacks extension: 1

  defmacro __using__(_opts) do
    quote do
      @behaviour Still.Preprocessor

      @spec run(SourceFile.t()) :: SourceFile.t()
      def run(file) do
        file
        |> set_extension()
        |> render()
      end

      def set_extension(file) do
        if Kernel.function_exported?(__MODULE__, :extension, 1) do
          %{file | extension: extension(file)}
        else
          file
        end
      end

      @spec extension(SourceFile.t()) :: String.t()
      def extension(file) do
        file.extension
      end

      defoverridable(extension: 1)
    end
  end
end
