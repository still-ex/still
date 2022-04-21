defmodule Still.Preprocessor.Pagination do
  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{metadata: %{pagination: %{data: data, size: size}} = metadata} = source_file) do
    chunks =
      data
      |> String.split(".")
      |> Enum.reduce(metadata, fn segment, acc ->
        fetch_key(acc, segment)
      end)
      |> Enum.chunk_every(size)

    chunks
    |> Enum.with_index(1)
    |> Enum.map(fn {page_items, page_nr} ->
      pagination = %{
        items: page_items,
        page_nr: page_nr,
        pages: chunks
      }

      %{source_file | metadata: %{pagination: pagination}}
    end)
  end

  def render(%{metadata: %{pagination: _}, input_file: input_file}) do
    raise ":pagination is not properly set in #{input_file}"
  end

  def render(source_file), do: source_file

  defp fetch_key(obj, key) when is_binary(key) do
    Map.get(obj, key, Map.get(obj, String.to_atom(key), %{}))
  end

  defp fetch_key(obj, key) when is_atom(key) do
    Map.get(obj, key, Map.get(obj, Atom.to_string(key), %{}))
  end
end
