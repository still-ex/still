defmodule Still.Preprocessor do
  alias Still.SourceFile
  alias Still.Compiler.PreprocessorError

  require Logger

  alias __MODULE__.{
    CSSMinify,
    EEx,
    Frontmatter,
    JS,
    Markdown,
    OutputPath,
    OutputPath,
    Slime,
    URLFingerprinting,
    Save,
    AddLayout,
    AddContent,
    Image
  }

  @default_preprocessors %{
    ".slim" => [AddContent, EEx, Frontmatter, Slime, OutputPath, AddLayout, Save],
    ".slime" => [AddContent, EEx, Frontmatter, Slime, OutputPath, AddLayout, Save],
    ".eex" => [AddContent, EEx, Frontmatter, OutputPath, AddLayout, Save],
    ".css" => [AddContent, EEx, CSSMinify, OutputPath, URLFingerprinting, AddLayout, Save],
    ".js" => [AddContent, EEx, JS, OutputPath, URLFingerprinting, AddLayout, Save],
    ".md" => [AddContent, EEx, Frontmatter, Markdown, OutputPath, AddLayout, Save],
    ".jpg" => [OutputPath, Image],
    ".png" => [OutputPath, Image]
  }

  @spec run(SourceFile.t()) :: SourceFile.t()
  def run(file) do
    file
    |> run(__MODULE__.for(file))
  end

  @spec run(SourceFile.t(), list(module())) :: SourceFile.t()
  def run(file, []) do
    file
  end

  def run(file, [preprocessor | remaining_preprocessors]) do
    preprocessor.run(file)
    |> run(remaining_preprocessors)
  catch
    :error, %{description: description} ->
      raise PreprocessorError,
        message: description,
        preprocessor: preprocessor,
        remaining_preprocessors: remaining_preprocessors,
        source_file: file,
        stacktrace: __STACKTRACE__

    :error, e ->
      Logger.error(inspect(e))

      case e do
        %PreprocessorError{} ->
          raise e

        e ->
          raise PreprocessorError,
            message: inspect(e),
            preprocessor: preprocessor,
            remaining_preprocessors: remaining_preprocessors,
            source_file: file,
            stacktrace: __STACKTRACE__
      end
  end

  def for(%{input_file: file} = source_file) do
    preprocessors()[Path.extname(file)]
    |> case do
      nil ->
        raise PreprocessorError,
          message: "Preprocessors not found for #{file}",
          source_file: source_file

      preprocessors ->
        preprocessors
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
