defmodule Still.Compiler.ViewHelpers do
  defmacro __using__(metadata) do
    quote do
      alias Still.SourceFile

      alias Still.Compiler.{
        Incremental,
        ViewHelpers.Link,
        ViewHelpers.UrlFor,
        ViewHelpers.LinkToCSS,
        ViewHelpers.LinkToJS
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

      def responsive_image(file, metadata \\ %{}) do
        with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
             %{output_file: output_file, metadata: %{image_sizes: sizes}} <-
               Incremental.Node.render(pid, metadata) do
          {_, biggest} = sizes |> List.last()

          srcset =
            sizes
            |> Enum.map(fn {size, file} ->
              "#{file |> url_for()} #{size}w"
            end)
            |> Enum.join(", ")

          """
            <img
              src=#{biggest |> url_for()}
              srcset="#{srcset}"
            />
          """
        else
          _ ->
            Logger.error("File process not found for #{file}")
            ""
        end
      end

      def expand_file(file) do
        Path.join(Path.dirname(@env[:input_file]), file)
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

      def link_to_css(path, opts \\ []) do
        LinkToCSS.render(path, opts)
      end

      def link_to_js(path, opts \\ []) do
        LinkToJS.render(path, opts)
      end

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
