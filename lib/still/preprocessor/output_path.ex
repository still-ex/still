defmodule Still.Preprocessor.OutputPath do
  @moduledoc """
  Sets the output path of a file.
  If the key `:permalink` is present in the metadata, it is used as the output path.
  If not, the output path is set using the `:input_file` and `:extension` keys.

  `:permalink` can use EEx interpolation and reference most variables that would have been available in the templates.
  For instance, combined with pagination, one can change the generated output like so:

  ```
  permalink: data/<%= pagination.page_nr + 1 %>.html
  pagination:
    data: some.global.data
    size: 3
  ---
  ```

  So the first page is `data/2.html` instead of the default `data/1.html`.

  This preprocessor is bypassed when the `:output_path` key is already set.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{output_file: output_file} = source_file) when not is_nil(output_file) do
    source_file
  end

  def render(%{metadata: %{permalink: permalink} = metadata} = source_file) do
    bindings = Enum.map(metadata, fn {key, value} -> {key, value} end)

    output_file = EEx.eval_string(permalink, bindings)

    %{source_file | output_file: output_file}
  end

  def render(
        %{
          input_file: input_file,
          extension: extension,
          metadata: %{pagination: %{page_nr: page_nr}}
        } = source_file
      )
      when not is_nil(extension) do
    output_file =
      input_file
      |> remove_extension()
      |> Path.join("#{page_nr}")
      |> Kernel.<>(extension)

    %{source_file | output_file: output_file}
  end

  def render(%{input_file: input_file, extension: extension} = source_file)
      when not is_nil(extension) do
    output_file =
      input_file
      |> remove_extension()
      |> Kernel.<>(extension)

    %{source_file | output_file: output_file}
  end

  def render(%{input_file: input_file} = source_file) do
    %{source_file | output_file: input_file}
  end

  defp remove_extension(file) do
    file
    |> String.split(".")
    |> hd()
  end
end
