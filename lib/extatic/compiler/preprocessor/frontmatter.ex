defmodule Extatic.Compiler.Preprocessor.Frontmatter do
  alias Extatic.Compiler.Preprocessor
  alias Extatic.Utils

  require Logger

  @behaviour Preprocessor

  @impl true
  def render(content, variables) do
    [frontmatter, content] = parse_frontmatter(content)

    settings =
      frontmatter
      |> parse_yaml()
      |> Map.merge(variables)
      |> set_permalink()

    {content, settings}
  end

  defp set_permalink(variables = %{permalink: _}), do: variables

  defp set_permalink(variables = %{file_path: file_path}) do
    variables
    |> Map.put(:permalink, String.replace(file_path, Path.extname(file_path), ".html"))
  end

  defp set_permalink(variables), do: variables

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
