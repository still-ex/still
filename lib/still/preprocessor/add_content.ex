defmodule Still.Preprocessor.AddContent do
  @moduledoc """
  `Still.Preprocessor` that reads the content of the input file and sets it to
  the `:content` field of `Still.SourceFile`.
  """
  alias Still.{Preprocessor, SourceFile}

  import Still.Utils

  use Preprocessor

  require Logger

  @impl true
  def render(%{content: content, input_file: input_file} = file) when is_nil(content) do
    %SourceFile{file | content: get_content(input_file)}
  end

  def render(file), do: file

  defp get_content(file) do
    case get_from_cache(file) do
      {:ok, content} when not is_nil(content) ->
        content

      _ ->
        file
        |> get_from_filesystem!()
        |> update_cache(file)
    end
  end

  defp get_from_cache(file) do
    Still.Compiler.ContentCache.get(file)
  end

  defp get_from_filesystem!(file) do
    File.read!(get_input_path(file))
  end

  defp update_cache(content, file) do
    Still.Compiler.ContentCache.set(file, content)
    content
  end
end
