if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime do
    require Logger
    require Slime

    @type file :: {:file_path, String.t()}

    @spec render(String.t(), [file, ...]) :: String.t() | no_return()
    def render(content, variables \\ []) do
      do_render(content, variables)
    rescue
      e in Slime.TemplateSyntaxError ->
        raise Extatic.Compiler.Preprocessor.SyntaxError,
          message: e.message,
          line_number: e.line_number,
          line: e.line,
          column: e.column
    end

    defp do_render(content, variables) do
      variables[:file_path]
      |> file_path_to_module_name()
      |> create_slime_view_renderer(content, variables)
      |> apply(:render, variables |> Enum.into(%{}) |> Map.values())
    end

    defp file_path_to_module_name(file) do
      name =
        Path.split(file)
        |> Enum.reject(&Enum.member?(["/", ".slime"], &1))
        |> Enum.map(&String.replace(&1, ".slime", ""))
        |> Enum.map(&String.replace(&1, "_", ""))
        |> Enum.map(&String.capitalize/1)

      Module.concat([Extatic.Compiler.Preprocessor.Slime | name])
    end

    defp create_slime_view_renderer(name, content, variables) do
      compiled = compile_slime(content, variables)
      args = get_args(variables)

      ast =
        quote do
          @compile :nowarn_unused_vars

          require Slime
          require EEx

          use Extatic.Compiler.ViewHelpers, unquote(Macro.escape(variables))

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
  end
end
