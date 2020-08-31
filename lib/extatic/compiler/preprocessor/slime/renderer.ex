if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime.Renderer do
    alias Extatic.Compiler.Preprocessor

    def create(content, variables) do
      variables[:file_path]
      |> file_path_to_module_name()
      |> create_slime_view_renderer(content, variables)
    end

    defp file_path_to_module_name(file) do
      name =
        Path.split(file)
        |> Enum.reject(&Enum.member?(["/", ".slime"], &1))
        |> Enum.map(&String.replace(&1, ".slime", ""))
        |> Enum.map(&String.replace(&1, "_", ""))
        |> Enum.map(&String.capitalize/1)

      Module.concat([Preprocessor.Slime | name])
    end

    defp create_slime_view_renderer(name, content, variables) do
      compiled = compile_slime(content, variables)
      args = get_args(variables)

      module_variables =
        variables
        |> ensure_current_context()
        |> ensure_preprocessor()

      ast =
        quote do
          @compile :nowarn_unused_vars

          require Slime
          require EEx

          use Extatic.Compiler.ViewHelpers, unquote(Macro.escape(module_variables))

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

    defp compile_slime(content, variables) do
      info = [file: __ENV__.file, line: __ENV__.line]

      Slime.Renderer.precompile(content)
      |> EEx.compile_string(info)
      |> ignore_unused_variables(variables)
    end

    defp ignore_unused_variables(ast, variables) do
      Enum.reduce(variables, ast, fn {k, _v}, memo ->
        quote do
          _ = var!(unquote(Macro.var(k, __MODULE__)))
          unquote(memo)
        end
      end)
    end

    defp ensure_current_context(variables) do
      Keyword.put_new(variables, :current_context, variables[:file_path])
    end

    defp ensure_preprocessor(variables) do
      Keyword.put_new(variables, :preprocessor, Preprocessor.Slime)
    end
  end
end
