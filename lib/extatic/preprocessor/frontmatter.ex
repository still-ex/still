defmodule Extatic.Preprocessor.Frontmatter do
  alias Extatic.Preprocessor
  alias Extatic.Utils

  require Logger

  use Preprocessor

  @impl true
  def render(content, variables) do
    [frontmatter, content] = parse_frontmatter(content)

    settings =
      frontmatter
      |> parse_yaml()
      |> Map.merge(variables)

    %{content: content, variables: settings}
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
      {:ok, variables} ->
        Utils.Map.deep_atomify_keys(variables)

      _ ->
        Logger.error("Failed parsing frontmatter\n#{yaml}")
        %{}
    end
  end
end
