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
    %SourceFile{file | content: File.read!(get_input_path(input_file))}
  end

  def render(file), do: file
end
