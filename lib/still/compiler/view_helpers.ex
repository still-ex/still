defmodule Still.Compiler.ViewHelpers do
  defmacro __using__(variables) do
    quote do
      alias Still.Compiler.{
        Context,
        Incremental,
        ViewHelpers.Link
      }

      alias __MODULE__

      require Logger

      @env unquote(variables)

      def include(file, variables \\ %{}) do
        with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
             {:ok, content, _settings} <-
               Incremental.Node.render(pid, variables, @env[:file_path]) do
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

      def link(content, opts) do
        Link.render(content, @env, opts)
      end

      def cssmin(code) do
        %{content: content} = Still.Preprocessor.CSSMinify.render(code, %{})
        content
      end
    end
  end
end
