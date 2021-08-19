defmodule Still.Preprocessor.URLFingerprinting do
  @moduledoc """
  Creates a hash based on the content of the file and generates a fingerprint
  to replace the output file.
  """

  alias Still.Preprocessor

  import Still.Utils, only: [config: 2]

  use Preprocessor

  @impl true
  def render(%{run_type: :compile_metadata} = source_file),
    do: source_file

  def render(%{output_file: nil} = source_file),
    do: source_file

  def render(file) do
    if enabled?() do
      do_render(file)
    else
      file
    end
  end

  defp do_render(%{content: content, output_file: output_file} = file) do
    hash =
      :crypto.hash(:md5, content)
      |> Base.url_encode64()

    ext =
      output_file
      |> Path.extname()

    %{file | output_file: String.replace_suffix(output_file, ext, "-#{hash}#{ext}")}
  end

  def enabled? do
    config(:url_fingerprinting, false)
  end
end
