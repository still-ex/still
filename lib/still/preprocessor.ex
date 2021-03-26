defmodule Still.Preprocessor do
  @moduledoc """
  Defines functions to be used by the several preprocessors as well as the
  behaviour they should have.

  Preprocessors are the cornerstone of Still. A preprocessor chain can take a
  markdown file, execute its embedded Elixir, extract metadata from its front
  matter, transform it into HTML and wrap it in a layout.

  There are a few defined chains by default, but you can extend Still with your
  own.

  **A custom preprocessor is simply a module that calls `use Still.Preprocessor`
  and implements the `render/1`function.**

  Take the following example:

      defmodule YourSite.JPEG do
        use Still.Preprocessor

        @impl true
        def render(file) do
          file
        end
      end

  In this example, the `render/1` function is used to transform the content and
  the metadata of a #{Still.SourceFile}.

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
        []

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

  defp do_run(file, [preprocessor | next_preprocessors]) do
    preprocessor.run(file, next_preprocessors)
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
  @callback after_render(SourceFile.t()) :: SourceFile.t()

  @optional_callbacks render: 1, after_render: 1

  defmacro __using__(_opts) do
    quote do
      @behaviour Still.Preprocessor

      @doc """
      Runs the #{Still.SourceFile} through the current preprocessor and the next.
      """
      @spec run(SourceFile.t()) :: SourceFile.t()
      def run(source_file) do
        run(source_file, [])
      end

      @spec run(SourceFile.t(), any()) :: SourceFile.t()
      def run(source_file, next_preprocessors) do
        source_file
        |> render()
        |> case do
          {:cont, source_file} ->
            source_file
            |> run_next_preprocessors(next_preprocessors)

          {:halt, source_file} ->
            source_file

          %SourceFile{} = source_file ->
            source_file
            |> run_next_preprocessors(next_preprocessors)
        end
        |> after_render()
      catch
        _, %PreprocessorError{} = error ->
          raise error

        kind, payload ->
          raise PreprocessorError,
            payload: payload,
            kind: kind,
            preprocessor: __MODULE__,
            remaining_preprocessors: next_preprocessors,
            source_file: source_file,
            stacktrace: __STACKTRACE__
      end

      defp run_next_preprocessors(source_file, []), do: source_file

      defp run_next_preprocessors(source_file, [next_preprocess | remaining_preprocesors]) do
        next_preprocess.run(source_file, remaining_preprocesors)
      end

      @doc """
      Runs after the next preprocessors finish running.

      Returns the resulting #{Still.SourceFile}.
      """
      @spec after_render(SourceFile.t()) :: SourceFile.t()
      def after_render(source_file), do: source_file

      @doc """
      Runs the current preprocessor and invokes the next one.

      Returns the resulting #{Still.SourceFile}.
      """
      @spec render(SourceFile.t()) ::
              {:cont, SourceFile.t()} | {:halt, SourceFile.t()} | SourceFile.t()
      def render(source_file), do: source_file

      defoverridable render: 1, after_render: 1
    end
  end
end
