defmodule Extatic.Compiler.Filters.JSmin do
  alias Extatic.Compiler.Filters

  @behaviour Filters.Filter

  @impl true
  def apply(content, _) do
    case minify(content) do
      {:ok, %{"code" => code}} -> code
      {:error, error} -> raise Filters.RuntimeError, message: error
    end
  end

  defp minify(content) do
    NodeJS.call({"terser", :minify}, [content])
  end
end
