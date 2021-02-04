defmodule Still.Compiler.ViewHelpers.ResponsiveImage do
  @moduledoc """
  Generates a set of images to ensure they are responsive.

  See `Still.Preprocessor.Image` for details on these transformations.
  """

  alias Still.Compiler.Incremental
  alias Still.Compiler.ViewHelpers.{ContentTag, UrlFor}

  import Still.Utils

  require Logger

  @default_nr_of_sizes 4

  @doc """
  Returns an image tag with the `src` and `srcset`.

  If `:image_opts` is set in `opts`, it will be passed on to
  `Still.Preprocessor.Image`.

  If `:sizes` is not set in the `:image_opts` map, it is assumed to be 25%,
  50%, 75% and 100% of the input file's width.
  """
  @spec render(file :: String.t(), list()) :: String.t()
  def render(file, opts \\ []) do
    {image_opts, opts} = Keyword.pop(opts, :image_opts, %{})

    output_files =
      file
      |> do_render(image_opts)
      |> get_output_files()

    ContentTag.render("img", nil, [
      {:src, render_src(output_files)},
      {:srcset, render_srcset(output_files)} | opts
    ])
  end

  defp do_render(file, image_opts) do
    Incremental.Registry.get_or_create_file_process(file)
    |> Incremental.Node.render(get_render_data(file, image_opts))
  end

  defp get_output_files(%{metadata: %{image_output_files: output_files}}) do
    output_files |> Enum.sort_by(&elem(&1, 0))
  end

  defp render_src(output_files) do
    {_, biggest_output_file} = output_files |> List.last()
    UrlFor.render(biggest_output_file)
  end

  defp render_srcset(output_files) do
    output_files
    |> Enum.map(fn {size, file} ->
      "#{UrlFor.render(file)} #{size}w"
    end)
    |> Enum.join(", ")
  end

  defp get_render_data(_, %{sizes: _} = image_opts) do
    %{image_opts: image_opts}
  end

  defp get_render_data(file, image_opts) do
    {:ok, %{width: width}} =
      file
      |> get_input_path()
      |> get_image_info()

    step_width = Integer.floor_div(width, @default_nr_of_sizes)

    image_opts =
      image_opts
      |> Map.put(
        :sizes,
        1..@default_nr_of_sizes
        |> Enum.map(&(&1 * step_width))
      )

    %{image_opts: image_opts}
  end
end
