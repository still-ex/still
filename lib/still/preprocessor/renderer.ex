defmodule Still.Preprocessor.Renderer do
  @type ast :: {atom(), keyword(), list()}

  @callback extensions :: [String.t()]

  @callback preprocessor :: atom()

  @callback compile(String.t(), [{atom(), any()}]) :: ast()

  @callback ast_steps :: ast()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      def create(content, variables) do
        variables[:file_path]
        |> file_path_to_module_name()
        |> create_view_renderer(content, variables)
      end

      defp file_path_to_module_name(file) do
        name =
          Path.split(file)
          |> reject_extensions()
          |> replace_extensions()
          |> Enum.map(&String.replace(&1, "_", ""))
          |> Enum.map(&String.capitalize/1)

        Module.concat([preprocessor() | name])
      end

      defp create_view_renderer(name, content, variables) do
        compiled =
          compile(content, variables)
          |> ignore_unused_variables(variables)

        args = get_args(variables)

        module_variables =
          variables
          |> ensure_current_context()
          |> ensure_preprocessor()
          |> Map.to_list()

        nowarn_ast =
          quote do
            @compile :nowarn_unused_vars
          end

        renderer_ast = ast_steps()

        function_ast =
          quote do
            use Still.Compiler.ViewHelpers, unquote(Macro.escape(module_variables))

            def render(unquote_splicing(args)) do
              unquote(compiled)
            end
          end

        ast =
          quote do
            unquote(nowarn_ast)
            unquote(renderer_ast)
            unquote(function_ast)
          end

        with {:module, mod, _, _} <- Module.create(name, ast, Macro.Env.location(__ENV__)) do
          mod
        end
      end

      defp get_args(variables) do
        info = [file: __ENV__.file, line: __ENV__.line]

        Enum.map(Map.new(variables) |> Map.keys(), fn arg ->
          {arg, [line: info[:line]], nil}
        end)
      end

      defp ignore_unused_variables(ast, variables) do
        Enum.reduce(variables, ast, fn {k, _v}, memo ->
          quote do
            _ = var!(unquote(Macro.var(k, __MODULE__)))
            unquote(memo)
          end
        end)
      end

      defp reject_extensions(path) do
        blacklist = List.flatten(["/", extensions()])

        Enum.reject(path, &Enum.member?(blacklist, &1))
      end

      defp replace_extensions(path) do
        Enum.map(path, &String.replace(&1, extensions(), ""))
      end

      defp ensure_current_context(variables) do
        Map.put_new(variables, :current_context, variables[:file_path])
      end

      defp ensure_preprocessor(variables) do
        Map.put_new(variables, :preprocessor, preprocessor())
      end
    end
  end
end
