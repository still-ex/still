defmodule Still.Preprocessor do
  @moduledoc """
  Defines functions to be used by the several preprocessors as well as the
  behaviour they should have.

  Preprocessors are the cornerstone of Still. A preprocessor chain can take a
  markdown file, execute its embedded Elixir, extract metadata from its front
  matter, transform it into HTML and wrap it in a layout.

  The default preprocessor chain is the following:

      %{
        ".slim" => [AddContent, EEx, Frontmatter, Slime, OutputPath, AddLayout, Save],
        ".slime" => [AddContent, EEx, Frontmatter, Slime, OutputPath, AddLayout, Save],
        ".eex" => [AddContent, EEx, Frontmatter, OutputPath, AddLayout, Save],
        ".css" => [AddContent, EEx, CSSMinify, OutputPath, URLFingerprinting, AddLayout, Save],
        ".js" => [AddContent, EEx, JS, OutputPath, URLFingerprinting, AddLayout, Save],
        ".md" => [AddContent, EEx, Frontmatter, Markdown, OutputPath, AddLayout, Save],
        ".jpg" => [OutputPath, Image],
        ".png" => [OutputPath, Image]
      }


  If the default preprocessors are not enough, you can extend Still with your
  own.

  **A custom preprocessor is simply a module that calls `use Still.Preprocessor`
  and implements the `render/2` and `extension/1` functions.**

  Take the following example:

      defmodule YourSite.JPEG do
        use Still.Preprocessor

        @impl true
        def extension(_), do: ".jpeg"

        @impl true
        def render(file) do
          file
        end
      end

  In this example, the `render/1` function is used to transform the content and
  the metadata of a file, and the `extension/1` function is used to set the
  resulting content type.  This `extension/1` function is not mandatory.

  See the [preprocessor guide](preprocessors.html) for more details.
  """

  alias Still.Compiler.PreprocessorError
  alias Still.Profiler
  alias Still.SourceFile

  require Logger

  import Still.Utils, only: [config: 2]

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

  @doc """
  Runs the preprocessor pipeline for the given file.
  """
  @spec run(SourceFile.t()) :: SourceFile.t() | {:error, any()}
  def run(file) do
    file
    |> run(__MODULE__.for(file))
  end

  @spec run(SourceFile.t(), list(module())) :: SourceFile.t() | {:error, any()}
  def run(file, []) do
    file
  end

  def run(file, preprocessors) do
    if should_profile?(file) do
      run_with_profiler(file, preprocessors)
    else
      do_run(file, preprocessors)
    end
  end

  @doc """
  Retrieves the preprocessor pipeline for the given file.
  """
  def for(%{input_file: file}) do
    preprocessors()[Path.extname(file)]
    |> case do
      nil ->
        Logger.warn("Preprocessors not found for file: #{file}")

      preprocessors ->
        preprocessors
    end
  end

  defp run_with_profiler(file, preprocessors) do
    start_time = Profiler.timestamp()

    response = do_run(file, preprocessors)

    end_time = Profiler.timestamp()
    Profiler.register(response, end_time - start_time)

    response
  end

  defp do_run(file, [preprocessor | remaining_preprocessors]) do
    preprocessor.run(file)
    |> run(remaining_preprocessors)
  catch
    :error, %PreprocessorError{} = e ->
      raise e

    :error, %{description: description} when description != "" ->
      raise PreprocessorError,
        message: description,
        preprocessor: preprocessor,
        remaining_preprocessors: remaining_preprocessors,
        source_file: file,
        stacktrace: __STACKTRACE__

    :error, e ->
      raise PreprocessorError,
        message: inspect(e),
        preprocessor: preprocessor,
        remaining_preprocessors: remaining_preprocessors,
        source_file: file,
        stacktrace: __STACKTRACE__
  end

  defp preprocessors do
    Map.merge(@default_preprocessors, user_defined_preprocessors())
  end

  defp user_defined_preprocessors do
    config(:preprocessors, %{})
  end

  defp should_profile?(%SourceFile{profilable: profilable}) do
    profilable and Application.get_env(:still, :profiler, false)
  end

  @callback render(SourceFile.t()) :: SourceFile.t()
  @callback extension(SourceFile.t()) :: String.t()
  @optional_callbacks extension: 1

  defmacro __using__(_opts) do
    quote do
      @behaviour Still.Preprocessor

      @doc """
      Sets the extension for the current file and calls the `render/1` function.
      """
      @spec run(SourceFile.t()) :: SourceFile.t()
      def run(file) do
        file
        |> set_extension()
        |> render()
      end

      @doc """
      Returns the extension for the current file.

      This function can be overridden.
      """
      @spec extension(SourceFile.t()) :: String.t()
      def extension(file) do
        file.extension
      end

      defp set_extension(file) do
        if Kernel.function_exported?(__MODULE__, :extension, 1) do
          %{file | extension: extension(file)}
        else
          file
        end
      end

      defoverridable(extension: 1)
    end
  end
end
