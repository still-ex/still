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
        file = unquote(variables)[:file_path]
        ctx = unquote(variables)[:current_context]

        Context.put(file, ctx, variable, content)

        :ok
      end

      def get(variable) do
        file = unquote(variables)[:file_path]
        ctx = unquote(variables)[:current_context]

        Context.get(file, ctx, variable)
      end

      def link(content, opts) do
        Link.render(content, unquote(variables), opts)
      end
    end
  end
end
