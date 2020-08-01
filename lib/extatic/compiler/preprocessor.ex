defmodule Extatic.Compiler.Preprocessor do
  alias Extatic.Compiler.Preprocessor

  @supported_preprocessors %{
    ".slim" => Preprocessor.Slime,
    ".slime" => Preprocessor.Slime,
    ".eex" => Preprocessor.EEx
  }

  @callback render(String.t(), keyword()) :: String.t()
  @callback content_tag(String.t(), String.t(), keyword()) :: String.t()

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
