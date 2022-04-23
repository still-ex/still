defmodule Still.Preprocessor.Pagination do
  @moduledoc """
  Paginates a `Still.SourceFile` if the key `:pagination` is present.
  The `:pagination` must be a hash containing the following keys:

  * `:data` - The data to paginate. This should be valid Elixir that returns a
              list. You can reference any variable in `:metadata` as you would in a
              template. For instance, you can return a global data file. See `Still.Data`
              for more information.
  * `:size` -  The number of items per page.

  Each `Still.SourceFile` will have a new `:pagination` key with the following format:

  ```
  %{
    items: [1, 2],
    page_nr: 1,
    pages: [[1, 2], [3, 4], [5, 6]]
  }
  ```

  Where `:items` is the data of the current page; `:page_nr` is the number of
  the current page; and `:pages` is the data of all pages.
  You can reference `:pagination` in your templates.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{metadata: %{pagination: %{data: data, size: size}} = metadata} = source_file) do
    bindings = get_bindings(metadata)

    with {pagination_data, _} when is_list(pagination_data) <- Code.eval_string(data, bindings) do
      chunks = Enum.chunk_every(pagination_data, size)

      chunks
      |> Enum.with_index(1)
      |> Enum.map(fn {page_items, page_nr} ->
        pagination = %{
          items: page_items,
          page_nr: page_nr,
          pages: chunks
        }

        %{source_file | metadata: %{metadata | pagination: pagination}}
      end)
    else
      _ ->
        raise "Failed to eval \"#{data}\""
    end
  end

  def render(source_file), do: source_file

  defp get_bindings(metadata) do
    Enum.map(metadata, fn {key, value} -> {key, value} end)
  end
end
