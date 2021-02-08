defmodule Still.Preprocessor.Image do
  @moduledoc """
  Handles image transformation.

  To configure it, set `:image_opts` in the metadata:

      %{
        image_opts: %{
          sizes: [100, 200],
          transformations: [color_filter: "grayscale_bt709"]
        }
      }

  `:sizes` defines the widths of the output files to create.

  `:transformations` defines the function name and arguments to call on the
  adapter. By default, the adapter is `Still.Preprocessor.Image.Mogrify`.
  However you can also include your own or make use of
  `Still.Preprocessor.Image.Imageflow` by adding `:still_imageflow` as a
  dependency and setting in your config:

    config :still, :image_adapter, Still.Preprocessor.Image.Imageflow

  For more information see [Mogrify](https://github.com/route/mogrify)'s
  options or [ImageMagick's
  docs](https://imagemagick.org/script/command-line-options.php) information.

  When `:image_opts` is not set, it copies the input file to the output
  file as it is.
  """

  use Still.Preprocessor

  import Still.Utils

  @impl true
  def render(%{metadata: %{image_opts: _opts}} = source_file) do
    adapter().render(source_file)
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

  def adapter do
    config(:image_adapter, __MODULE__.Mogrify)
  end
end
