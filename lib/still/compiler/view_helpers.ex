defmodule Still.Compiler.ViewHelpers do
  defmacro __using__(metadata) do
    quote do
      alias Still.SourceFile

      alias Still.Compiler.{
        Incremental,
        ViewHelpers.Link,
        ViewHelpers.UrlFor,
        ViewHelpers.LinkToCSS,
        ViewHelpers.LinkToJS,
        ViewHelpers.ContentTag,
        ViewHelpers.ResponsiveImage
      }

      alias __MODULE__

      require Logger

      @env unquote(metadata)

      def include(file, metadata \\ %{}, opts \\ [])

      def include(file, metadata, opts) when is_list(metadata) do
        include(file, metadata |> Enum.into(%{}), opts)
      end

      def include(file, metadata, opts) do
        with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
             subscriber <- include_subscriber(opts),
             %SourceFile{content: content} <- Incremental.Node.render(pid, metadata, subscriber) do
          if subscriber do
            Incremental.Node.add_subscription(self(), file)
          end

          content
        else
          _ ->
            Logger.error("File process not found for #{file}")
            ""
        end
      end

      defdelegate responsive_image(file, opts \\ []),
        to: ResponsiveImage,
        as: :render

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
      def path_expand(path) do
        Path.join(Path.dirname(@env[:input_file]), path)
      end

      def url_for(relative_path) do
        UrlFor.render(relative_path)
      end

      def get_collections(collection) do
        Still.Compiler.Collections.get(collection, @env[:input_file])
      end

      def link(content, opts) do
        Link.render(content, @env, opts)
      end

      defdelegate link_to_css(path, opts \\ []), to: LinkToCSS, as: :render

      defdelegate link_to_js(path, opts \\ []), to: LinkToJS, as: :render

      defp include_subscriber(opts) do
        if Keyword.get(opts, :subscribe, true) do
          @env[:input_file]
        else
          nil
        end
      end
    end
  end
end
