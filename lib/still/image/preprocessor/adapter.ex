defmodule Still.Image.Preprocessor.Adapter do
  @moduledoc """
  Adapter definition to be used by `Still.Image.Preprocessor`.

  An adapter implements the `render/1` function. It is only called when
  `:image_opts` are defined within the `:metadata` field of the source file
  (see `Still.SourceFile`).

  The `render/1` function should create several versions of the same images,
  given the `:sizes` and `:transformations` options. The purpose of this
  function is to support the `responsive_image/2 template helper`. See
  `Still.Image.TemplateHelpers.render/2` for details on how this
  template helper works.

  `:sizes` defines the widths of the output files to create.

  `:transformations` defines the function name and arguments to call on the
  adapter. By default, the adapter is `Still.Image.Preprocessor.Mogrify`.

  You can change the adapter by altering your config:

    config :still, :image_adapter, Still.Image.Preprocessor.Imageflow

  The `Imageflow` adapter requires you to have
  [`:still_imageflow`](https://github.com/still-ex/still_imageflow) as a
  dependency.
  """

  @callback render(%Still.SourceFile{}) :: %Still.SourceFile{}

  @callback get_image_info(file :: String.t()) ::
              {:ok, %{width: integer(), height: integer()}} | {:error, any()}

  defmacro __using__(_) do
    quote do
      @behaviour Still.Image.Preprocessor.Adapter
    end
  end
end
