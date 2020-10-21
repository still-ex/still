defmodule Still.Preprocessor.URLFingerprinting do
  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{output_file: nil} = file) do
    file
  end

  @impl true
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
    Application.get_env(:still, :url_fingerprinting, false)
  end
end
