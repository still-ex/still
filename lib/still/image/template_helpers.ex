defmodule Still.Image.TemplateHelpers do
  @moduledoc """
  Generates a set of images to ensure they are responsive.

  See `Still.Image.Preprocessor` for details on these transformations.
  """

  alias Still.SourceFile
  alias Still.Compiler.TemplateHelpers.{ContentTag, UrlFor}
  alias Still.Image.Preprocessor.OutputFile

  import Still.Utils

  require Logger

  @default_nr_of_sizes 4
  @no_responsive_image "no-responsive-image"

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

  @doc """
  Returns a list of #{Still.Image.Preprocessor.OutputFile} for the given input file.

  If `:sizes` or `:transformations` are present in `opts`, they will be passed
  to `Still.Image.Preprocessor`.

  If `:sizes` is not set, the default will be 25%, 50%, 75% and 100% of the
  input file's width.
  """
  @spec get_output_files(file :: String.t(), list()) :: list(OutputFile.t())
  def get_output_files(file, opts \\ []) do
    image_opts = Keyword.take(opts, [:sizes, :transformations])

    %{metadata: %{output_files: output_files}} = do_render(file, image_opts)

    Enum.sort_by(output_files, & &1.width)
  end

  @doc """
  Returns the file to be usd in a image's `src` attribute.
  """
  @spec render_src(list(OutputFile.t())) :: String.t()
  def render_src(output_files) do
    %{file: biggest_output_file} = output_files |> List.last()

    UrlFor.render(biggest_output_file)
  end

  @doc """
  Returns the file to be usd in a image's `srcset` attribute.
  """
  @spec render_srcset(list(OutputFile.t())) :: String.t()
  def render_srcset(output_files) do
    output_files
    |> Enum.map(fn %{width: size, file: file} ->
      "#{UrlFor.render(file)} #{size}w"
    end)
    |> Enum.join(", ")
  end

  @doc """
  Checks if a file is a supported image.
  """
  @spec is_img?(String.t()) :: boolean()
  def is_img?(src) do
    String.ends_with?(src, "png") || String.ends_with?(src, "jpeg") ||
      String.ends_with?(src, "jpg")
  end

  def no_responsive_image, do: @no_responsive_image

  defp do_render(file, image_opts) do
    opts = Map.new(image_opts)

    file
    |> render_file(get_render_data(file, opts))
    |> SourceFile.first()
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
