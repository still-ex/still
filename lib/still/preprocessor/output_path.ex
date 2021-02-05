defmodule Still.Preprocessor.OutputPath do
  @moduledoc """
  Generates the output path based on the `Still.SourceFile` `:input_path` and
  `:extension` field, adding it to the `:output_file` field.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{output_file: output_file} = file) when not is_nil(output_file) do
    file
  end

  def render(%{metadata: %{permalink: permalink}} = file) do
    %{file | output_file: permalink}
  end

  def render(%{input_file: input_file, extension: extension} = file)
      when not is_nil(extension) do
    output_file =
      input_file
      |> String.replace(Path.extname(input_file), extension)

    %{file | output_file: output_file}
  end

  def render(%{input_file: input_file} = file) do
    %{file | output_file: input_file}
  end
end
