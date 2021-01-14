defmodule Still.Preprocessor.Image do
  @moduledoc """
  This preprocessor handles image transformation. To configure
  it, set `:image_opts` in the metadata:

    %{
      image_opts: %{
        sizes: [100, 200],
        transformations: [color_filter: "grayscale_bt709"]
      }
    }

  `:sizes` defines the widths of the output files to create.

  `:transformations` defines the function name and arguments to call on the
  adapter. See [Imageflow's
  docs](https://docs.imageflow.io/introduction.html) and
  [`imageflow_ex`](https://github.com/naps62/imageflow_ex) or [ImageMagick's
  docs](https://imagemagick.org/script/command-line-options.php) for more
  information.

  When `:image_opts` is not set, it copies the input file to the output
  file as it is.
  """

  use Still.Preprocessor

  import Still.Utils

  if Code.ensure_loaded?(Imageflow) do
    @impl true
    def render(
          %{
            metadata: %{image_opts: _opts}
          } = source_file
        ) do
      __MODULE__.Imageflow.render(source_file)
    end
  else
    @impl true
    def render(
          %{
            metadata: %{image_opts: _opts}
          } = source_file
        ) do
      __MODULE__.Mogrify.render(source_file)
    end
  end

  @impl true
  def render(%{input_file: input_file, output_file: output_file} = source_file) do
    output_file
    |> Path.dirname()
    |> mk_output_dir()

    input_file
    |> get_input_path()
    |> File.cp!(get_output_path(output_file))

    source_file
  end
end
