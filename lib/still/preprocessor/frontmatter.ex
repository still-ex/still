defmodule Still.Preprocessor.Frontmatter do
  @moduledoc """
  Parses the file's frontmatter and adds they key/value pairs to the
  corresponding `Still.SourceFile`'s `:metadata` field.
  """

  alias Still.Preprocessor
  alias Still.Utils

  require Logger

  use Preprocessor

  @impl true
  def render(%{content: content, metadata: metadata} = file) do
    [frontmatter, content] = parse_frontmatter(content)

    metadata =
      frontmatter
      |> parse_yaml()
      |> Map.merge(metadata)

    %{file | content: content, metadata: metadata}
  end

  defp parse_frontmatter(content) do
    case String.split(content, ~r/\n-{3,}\n/, parts: 2) do
      [frontmatter, content] -> [frontmatter, content]
      [content] -> [nil, content]
    end
  end

  defp parse_yaml(nil), do: %{}

  defp parse_yaml(yaml) do
    case YamlElixir.read_from_string(yaml, atoms: true) do
      {:ok, metadata} ->
        Utils.Map.deep_atomify_keys(metadata)

      _ ->
        Logger.error("Failed parsing frontmatter\n#{yaml}")
        %{}
    end
  end
end
