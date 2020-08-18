defmodule Extatic.Compiler.File.Frontmatter do
  require Logger

  def parse(content) do
    with [frontmatter, content] <- parse_frontmatter(content),
         settings <- parse_yaml(frontmatter) do
      {:ok, settings, content}
    end
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
        variables
        |> keys_to_atoms()

      _ ->
        Logger.error("Failed parsing frontmatter\n#{yaml}")
        %{}
    end
  end

  defp keys_to_atoms(map) do
    map |> Enum.reduce(%{}, fn {k, v}, memo -> Map.put(memo, to_atom(k), v) end)
  end

  defp to_atom(key) when is_binary(key), do: key |> String.to_atom()
  defp to_atom(key), do: key
end
