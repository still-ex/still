defmodule Extatic.Compiler.Preprocessor do
  alias Extatic.Compiler.Preprocessor

  @supported_preprocessors %{
    ".slim" => [Preprocessor.Frontmatter, Preprocessor.Slime],
    ".slime" => [Preprocessor.Frontmatter, Preprocessor.Slime],
    ".eex" => [Preprocessor.Frontmatter, Preprocessor.EEx]
  }

  @callback render(String.t(), [...]) :: {String.t(), map()} | no_return()
  @callback extension() :: String.t()
  @optional_callbacks extension: 0

  def for(file) do
    preprocessor = @supported_preprocessors[Path.extname(file)]

    if preprocessor do
      {:ok, preprocessor}
    else
      {:error, :preprocessor_not_found}
    end
  end

  def supported_extensions do
    Map.keys(@supported_preprocessors)
  end
end
