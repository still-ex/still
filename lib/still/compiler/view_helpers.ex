defmodule Still.Compiler.ViewHelpers do
  defmacro __using__(variables) do
    quote do
      alias Still.SourceFile

      alias Still.Compiler.{
        Context,
        Incremental,
        ViewHelpers.Link,
        ViewHelpers.UrlFor,
        ViewHelpers.LinkToCSS,
        ViewHelpers.LinkToJS
      }

      alias __MODULE__

      require Logger

      @env unquote(variables)

      def include(file, variables \\ %{}) do
        with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
             %SourceFile{content: content} <-
               Incremental.Node.render(pid, variables, @env[:input_file]) do
          Incremental.Node.add_subscription(pid, file)
          content
        else
          _ ->
            Logger.error("File process not found for #{file}")
            ""
        end
      end

      def set(variable, do: content) do
        ctx = @env[:current_context]

        Context.put(ctx, variable, content)

        :ok
      end

      def get(variable) do
        ctx = @env[:current_context]

        Context.get(ctx, variable)
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

      def cssmin(code) do
        %{content: content} =
          Still.Preprocessor.CSSMinify.render(%SourceFile{
            content: code,
            input_file: @env[:input_file]
          })

        content
      end

      def link_to_css(path, opts \\ []) do
        LinkToCSS.render(path, opts, @env)
      end

      def link_to_js(path, opts \\ []) do
        LinkToJS.render(path, opts, @env)
      end
    end
  end
end
