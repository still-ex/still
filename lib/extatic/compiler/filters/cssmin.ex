defmodule Extatic.Compiler.Filters.CSSmin do
  alias Extatic.Compiler.Filters

  @behaviour Filters.Filter

  @impl true
  def apply(content, opts) do
    opts = Enum.into(%{}, opts)

    case minify(content, opts) do
      {:ok, %{"styles" => styles, "errors" => []}} ->
        styles

      {:ok, %{"errors" => errors}} ->
        raise Filters.RuntimeError, message: Enum.join(errors, "\n")

      {:error, error} ->
        raise Filters.RuntimeError, message: error
    end
  end

  defp minify(content, opts) do
    NodeJS.call({"js/cssmin", :minify}, [content, opts])
  end
end
