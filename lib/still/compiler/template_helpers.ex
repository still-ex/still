defmodule Still.Compiler.TemplateHelpers do
  @moduledoc """
  Set of helper functions to be included in a file that runs through an Elixir
  preprocessor.
  """

  alias Still.SourceFile

  alias Still.Compiler.{
    Incremental,
    PreprocessorError,
    TemplateHelpers.Link,
    TemplateHelpers.LinkToCSS,
    TemplateHelpers.LinkToJS,
    TemplateHelpers.SafeHTML,
    TemplateHelpers.Truncate,
    TemplateHelpers.UrlFor
  }

  import Still.Utils

  require Logger

  defdelegate responsive_image(file, opts \\ []),
    to: Still.Image.TemplateHelpers,
    as: :render_html

  defdelegate url_for(relative_path), to: UrlFor, as: :render

  defdelegate link_to_css(env, path, opts \\ []), to: LinkToCSS, as: :render

  defdelegate link_to_js(env, path, opts \\ []), to: LinkToJS, as: :render

  @doc """
  Renders a file in the page using the variables defined in `metadata`.
  """
  def include(env, file, metadata \\ %{})

  def include(env, file, metadata) when is_list(metadata) do
    include(env, file, metadata |> Enum.into(%{}))
  end

  def include(env, file, metadata) do
    ensure_file_exists!(file)

    metadata = Map.put(metadata, :dependency_chain, env[:dependency_chain])

    with source_files <- Incremental.Node.Render.run(file, metadata),
         %SourceFile{content: content} <- SourceFile.for_extension(source_files, env.extension) do
      content
    else
      %PreprocessorError{} = e ->
        raise e

      _ ->
        Logger.error("File process not found for #{file}")
        ""
    end
  end

  @doc """
  Converts a relative path to an absolute one.


  ## Examples

  File paths are always relative to the root folder, but sometimes it's too
  cumbersome, and we need to reference a file relative to the current
  folder.

  For instance, when called inside the file "blog/post/index.md":

      path_expand("./cover.png")
      # "blog/post/./cover.png"

  """
  def path_expand(env, path) do
    Path.join(Path.dirname(env[:input_file]), path)
  end

  @doc """
  Returns the collections for the current file.
  """
  def get_collections(_env, collection) do
    Still.Compiler.Collections.get(collection)
  end

  @doc """
  Renders the link using `Still.Compiler.TemplateHelpers.Link.render/3`.
  """
  def link(env, content, opts) do
    Link.render(env, content, opts)
  end

  @doc """
  Safely renders the content by escaping any HTML tags.
  """
  def safe_html(content) do
    SafeHTML.render(content)
  end

  @doc """
  Truncates the string.

  ## Options

  * `escape` - apply `safe_html/1` after truncating. Defaults to `false`.

  See further supported options in `Still.TemplateHelpers.Truncate`.
  """
  def truncate(str, opts \\ []) do
    truncated = Truncate.render(str, opts)

    if opts[:escape] do
      safe_html(truncated)
    else
      truncated
    end
  end

  defp ensure_file_exists!(file) do
    if not input_file_exists?(file) do
      raise "File #{file} does not exist in #{get_input_path()}"
    end
  end
end
