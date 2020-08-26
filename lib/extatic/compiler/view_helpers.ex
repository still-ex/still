defmodule Extatic.Compiler.ViewHelpers do
  defmacro __using__(variables) do
    quote do
      alias Extatic.{
        Context,
        FileRegistry,
        FileProcess
      }

      require Logger

      def include(file, variables \\ %{}) do
        with pid when not is_nil(pid) <- FileRegistry.get_or_create_file_process(file),
             {:ok, content, _settings} <-
               FileProcess.render(pid, variables, unquote(variables)[:file_path]) do
          FileProcess.add_subscription(pid, file)
          content
        else
          _ ->
            Logger.error("File process not found for #{file}")
            ""
        end
      end
    end
  end
end
