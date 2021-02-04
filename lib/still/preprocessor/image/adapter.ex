defmodule Still.Preprocessor.Image.Adapter do
  @moduledoc """
  Adapter definition to be used by `Still.Preprocessor.Image`.

  An adapter implements the `render/1` function. It is only called when
  `:image_opts` are defined within the `:metadata` field of the source file
  (see `Still.SourceFile`).

  The `render/1` function should create several versions of the same images,
  given the `:sizes` and `:transformations` options. The purpose of this
  function is to support the `responsive_image/2 view helper`. See
  `Still.Compiler.ViewHelpers.ResponsiveImage.render/2` for details on how this
  view helper works.

  `:sizes` defines the widths of the output files to create.

  `:transformations` defines the function name and arguments to call on the
  adapter. By default, the adapter is `Still.Preprocessor.Image.Mogrify`.

  You can change the adapter by altering your config:

    config :still, :image_adapter, Still.Preprocessor.Image.Imageflow

  The `Imageflow` adapter requires you to have
  [`:still_imageflow`](https://github.com/still-ex/still_imageflow) as a
  dependency.
  """

  @callback render(%Still.SourceFile{}) :: %Still.SourceFile{}

  @callback get_image_info(file :: String.to_atom()) ::
              {:ok, %{width: integer(), height: integer()}} | {:error, any()}

  defmacro __using__(_) do
    quote do
      @behaviour Still.Preprocessor.Image.Adapter
    end
  end
end
