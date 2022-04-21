defmodule Still.Preprocessor.Slime do
  @moduledoc """
  Renders a Slime file. See `Still.Preprocessor.Renderer` and
  `Still.Preprocessor.EEx.Renderer`.
  """

  require Slime

  alias Still.Preprocessor
  alias Still.Preprocessor.Slime.Renderer

  use Preprocessor

  @extension ".html"

  @impl true
  def render(%{run_type: :compile_metadata, metadata: %{pagination: _pagination}} = source_file) do
    source_file
    |> set_pagination()
    |> Enum.map(fn source_file ->
      %{source_file | extension: @extension}
    end)
  end

  def render(%{run_type: :compile_metadata} = source_file) do
    %{source_file | extension: @extension}
  end

  def render(%{metadata: %{pagination: _pagination}} = source_file) do
    source_file
    |> set_pagination()
    |> Enum.map(fn source_file ->
      %{source_file | content: do_render(source_file), extension: @extension}
    end)
  end

  def render(source_file) do
    %{source_file | content: do_render(source_file), extension: @extension}
  end

  defp do_render(source_file) do
    Renderer.create(source_file)
    |> apply(:render, [])
  end

  defp fetch_key(obj, key) when is_binary(key) do
    Map.get(obj, key, Map.get(obj, String.to_atom(key), %{}))
  end

  defp fetch_key(obj, key) when is_atom(key) do
    Map.get(obj, key, Map.get(obj, Atom.to_string(key), %{}))
  end

  def set_pagination(%{metadata: %{pagination: pagination} = metadata} = source_file) do
    pagination
    |> String.split(".")
    |> Enum.reduce(metadata, fn segment, acc ->
      fetch_key(acc, segment)
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {page, page_nr} ->
      metadata =
        metadata
        |> Map.put(:page, page)
        |> Map.put(:page_nr, page_nr)

      %{source_file | metadata: metadata}
    end)
  end
end
