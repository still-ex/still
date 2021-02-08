defmodule Still.Preprocessor.Renderer do
  @moduledoc """
  Defines the basic attributes of a markup renderer.

  A renderer needs to implement a `compile/2` function and an optional `ast/0`
  function. When a markup file is being compiled, a module is created on
  demand. This module imports all view helpers defined by Still as well as any
  view helper configured by the user:

      config :still,
        view_helpers: [Your.Module]

  The created module implements a `render/0` which will return the result of
  the `compile/2` call.

  The `ast/0` can be used to tap into the AST of the new module and import or
  require any necessary module.

  Markup renderers should `use` `Still.Preprocessor.Renderer` and provide two
  options:

  * `:extensions` - the list of extensions compiled by the renderer;
  * `:preprocessor` - the preprocessor used to render any necessary snippets
  (e.g via `Still.Compiler.ViewHelpers.ContentTag`).
  """
  @type ast :: {atom(), keyword(), list()}

  @callback compile(String.t(), [{atom(), any()}]) :: ast()

  @callback ast() :: ast()

  @optional_callbacks [ast: 0]

  import Still.Utils, only: [config: 2]

  alias Still.SourceFile

  defmacro __using__(opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @preprocessor Keyword.fetch!(unquote(opts), :preprocessor)
      @extensions Keyword.fetch!(unquote(opts), :extensions)

      def create(%SourceFile{input_file: input_file, content: content, metadata: metadata}) do
        metadata[:input_file]
        |> file_path_to_module_name()
        |> create_view_renderer(content, metadata)
      end

      defp file_path_to_module_name(file) do
        name =
          Path.split(file)
          |> Enum.reject(&Enum.member?(["/" | @extensions], &1))
          |> Enum.map(&String.replace(&1, @extensions, ""))
          |> Enum.map(&String.replace(&1, "_", ""))
          |> Enum.map(&String.capitalize/1)

        Module.concat(["R#{Enum.random(0..100_000)}" | [@preprocessor | name]])
      end

      defp create_view_renderer(name, content, metadata) do
        compiled = compile(content, metadata)

        module_metadata =
          metadata
          |> ensure_preprocessor()
          |> Map.to_list()

        renderer_ast =
          if Kernel.function_exported?(__MODULE__, :ast, 0) do
            ast()
          else
            []
          end

        ast =
          quote do
            @compile :nowarn_unused_vars

            unquote(user_view_helpers_asts())
            unquote(renderer_ast)

            use Still.Compiler.ViewHelpers, unquote(Macro.escape(module_metadata))

            Enum.map(unquote(Macro.escape(metadata)), fn {k, v} ->
              Module.put_attribute(__MODULE__, k, v)
            end)

            def render() do
              var!(unquote(Macro.var(:assigns, __MODULE__))) = unquote(Macro.escape(metadata))
              _ = var!(unquote(Macro.var(:assigns, __MODULE__)))
              unquote(compiled)
            end
          end

        with {:module, mod, _, _} <- Module.create(name, ast, Macro.Env.location(__ENV__)) do
          mod
        end
      end

      defp user_view_helpers_asts do
        config(:view_helpers, [])
        |> Enum.map(fn module ->
          quote do
            import unquote(module)
          end
        end)
      end

      defp ensure_preprocessor(metadata) do
        Map.put_new(metadata, :preprocessor, @preprocessor)
      end
    end
  end
end
