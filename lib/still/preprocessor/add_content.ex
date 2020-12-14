defmodule Still.Preprocessor.AddContent do
  alias Still.{Preprocessor, SourceFile}

  import Still.Utils

  use Preprocessor

  require Logger

  @impl true
  def render(%{content: content} = file) when is_nil(content) do
    with {:ok, content} <- File.read(get_input_path(file)) do
      %SourceFile{file | content: content}
    end
  end

  def render(file), do: file
end
