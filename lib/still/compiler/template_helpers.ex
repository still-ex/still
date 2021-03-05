defmodule Still.Compiler.TemplateHelpers do
  @moduledoc """
  Set of helper functions to be included in a file that runs through an Elixir
  preprocessor.
  """

  alias Still.SourceFile

  alias Still.Compiler.{
    Incremental,
    TemplateHelpers.Link,
    TemplateHelpers.UrlFor,
    TemplateHelpers.LinkToCSS,
    TemplateHelpers.LinkToJS,
    TemplateHelpers.ResponsiveImage,
    TemplateHelpers.SafeHTML,
    TemplateHelpers.Truncate,
    PreprocessorError
  }

  require Logger

  defdelegate responsive_image(_env, file, opts \\ []),
    to: ResponsiveImage,
    as: :render

  defdelegate url_for(relative_path), to: UrlFor, as: :render

  defdelegate link_to_css(path, opts \\ []), to: LinkToCSS, as: :render

  defdelegate link_to_js(path, opts \\ []), to: LinkToJS, as: :render

  @doc """
  Renders a file and includes it in the page, using the variables defined in `metadata`.

  By default, it creates a subscription to recompile the file in which
  `include/3` is invoked, when the target `file` changes. This behaviour
  can be disabled by passing the `:subscribe` option as `false`.
  """
  def include(env, file, metadata \\ %{}, opts \\ [])

  def include(env, file, metadata, opts) when is_list(metadata) do
    include(env, file, metadata |> Enum.into(%{}), opts)
  end

  def include(env, file, metadata, opts) do
    with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
         subscriber <- include_subscriber(env, opts),
         metadata <- Map.put(metadata, :dependency_chain, env[:dependency_chain] || []),
         %SourceFile{content: content} <- Incremental.Node.render(pid, metadata, subscriber) do
      if subscriber do
        Incremental.Node.add_subscription(self(), file)
      end

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
  def get_collections(env, collection) do
    Still.Compiler.Collections.get(collection, env[:input_file])
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

  defp include_subscriber(env, opts) do
    if Keyword.get(opts, :subscribe, true) do
      env[:input_file]
    else
      nil
    end
  end
end
