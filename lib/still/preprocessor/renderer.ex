defmodule Still.Preprocessor.Renderer do
  @type ast :: {atom(), keyword(), list()}

  @callback compile(String.t(), [{atom(), any()}]) :: ast()

  @callback ast() :: ast()

  @optional_callbacks [ast: 0]

  defmacro __using__(opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @preprocessor Keyword.fetch!(unquote(opts), :preprocessor)
      @extensions Keyword.fetch!(unquote(opts), :extensions)

      def create(content, variables) do
        variables[:file_path]
        |> file_path_to_module_name()
        |> create_view_renderer(content, variables)
      end

      defp file_path_to_module_name(file) do
        name =
          Path.split(file)
          |> Enum.reject(&Enum.member?(["/" | @extensions], &1))
          |> Enum.map(&String.replace(&1, @extensions, ""))
          |> Enum.map(&String.replace(&1, "_", ""))
          |> Enum.map(&String.capitalize/1)

        Module.concat([@preprocessor | name])
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

        renderer_ast =
          if Module.defines?(__MODULE__, {:ast, 0}) do
            ast()
          else
            []
          end

        ast =
          quote do
            @compile :nowarn_unused_vars

            unquote(user_view_helpers_asts())
            unquote(renderer_ast)

            use Still.Compiler.ViewHelpers, unquote(Macro.escape(module_variables))

            def render(unquote_splicing(args)) do
              unquote(compiled)
            end
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

      defp user_view_helpers_asts do
        :application.loaded_applications()
        |> Enum.map(fn {app, _, _} ->
          {:ok, mods} = :application.get_key(app, :modules)

          for module <- mods,
              Still.ViewHelper in (module.module_info(:attributes)[:behaviour] || []) do
            quote do
              import unquote(module)
            end
          end
        end)
        |> List.flatten()
      end

      defp ensure_current_context(variables) do
        Map.put_new(variables, :current_context, variables[:file_path])
      end

      defp ensure_preprocessor(variables) do
        Map.put_new(variables, :preprocessor, @preprocessor)
      end
    end
  end
end
