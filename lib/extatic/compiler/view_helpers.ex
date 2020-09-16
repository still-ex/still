defmodule Extatic.Compiler.ViewHelpers do
  defmacro __using__(variables) do
    quote do
      alias Extatic.Compiler.{
        Context,
        Incremental,
        ViewHelpers.Link
      }

      alias __MODULE__

      require Logger

      def include(file, variables \\ %{}) do
        with pid when not is_nil(pid) <- Incremental.Registry.get_or_create_file_process(file),
             {:ok, content, _settings} <-
               Incremental.Node.render(pid, variables, unquote(variables)[:file_path]) do
          Incremental.Node.add_subscription(pid, file)
          content
        else
          _ ->
            Logger.error("File process not found for #{file}")
            ""
        end
      end

      def set(variable, do: content) do
        ctx = unquote(variables)[:current_context]

        Context.put(ctx, variable, content)

        :ok
      end

      def get(variable) do
        ctx = unquote(variables)[:current_context]

        Context.get(ctx, variable)
      end

      def link(content, opts) do
        Link.render(content, unquote(variables), opts)
      end

      def cssmin(code) do
        %{content: content} = Extatic.Preprocessor.CSSMinify.render(code, %{})
        content
      end
    end
  end
end
