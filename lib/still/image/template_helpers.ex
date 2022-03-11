defmodule Still.Image.TemplateHelpers do
  @moduledoc """
  Generates a set of images to ensure they are responsive.

  See `Still.Image.Preprocessor` for details on these transformations.
  """

  alias Still.Compiler.Incremental
  alias Still.Compiler.TemplateHelpers.{ContentTag, UrlFor}

  import Still.Utils

  require Logger

  @default_nr_of_sizes 4

  @doc """
  Returns an image tag with the `src` and `srcset`.

  If `:sizes` or `:transformations` are present in `opts`, they will be passed
  to `Still.Image.Preprocessor`.

  If `:sizes` is not set, the default will be 25%, 50%, 75% and 100% of the
  input file's width.
  """
  @spec render_html(file :: String.t(), list()) :: String.t()
  def render_html(file, opts \\ []) do
    other_opts = Keyword.drop(opts, [:sizes, :transformations])

    output_files = get_output_files(file, opts)

    ContentTag.render("img", nil, [
      {:src, render_src(output_files)},
      {:srcset, render_srcset(output_files)} | other_opts
    ])
  end

  def get_output_files(file, opts \\ []) do
    image_opts = Keyword.take(opts, [:sizes, :transformations])

    %{metadata: %{output_files: output_files}} = do_render(file, image_opts)

    Enum.sort_by(output_files, & &1.width)
  end

  def render_src(output_files) do
    %{file: biggest_output_file} = output_files |> List.last()

    UrlFor.render(biggest_output_file)
  end

  def render_srcset(output_files) do
    output_files
    |> Enum.map(fn %{width: size, file: file} ->
      "#{UrlFor.render(file)} #{size}w"
    end)
    |> Enum.join(", ")
  end

  defp do_render(file, image_opts) do
    opts = Map.new(image_opts)

    Incremental.Registry.get_or_create_file_process(file)
    |> Incremental.Node.render(get_render_data(file, opts))
  end

  defp get_render_data(file, %{sizes: _} = image_opts) do
    %{image_opts: image_opts, dependency_chain: [file]}
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

    %{image_opts: image_opts, dependency_chain: [file]}
  end
end
