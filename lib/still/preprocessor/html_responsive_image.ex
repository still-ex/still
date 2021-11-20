defmodule Still.Preprocessor.HtmlResponsiveImage do
  @no_responsive_image "no-responsive-image"

  @moduledoc """
  Parses an HTML `Still.SourceFile` and replaces HTML img with responsive images.
  Images that have the attributes "srcset" or "#{@no_responsive_image}" are ignored.
  """

  alias Still.{SourceFile, Preprocessor}
  alias Still.Compiler.TemplateHelpers.ResponsiveImage

  use Preprocessor

  import Still.Utils

  def render(
        %SourceFile{
          extension: ".html",
          content: content,
          input_file: input_file
        } = source_file
      ) do
    {:ok, document} = Floki.parse_document(content)

    new_content =
      document
      |> Floki.find_and_update("img", fn
        {"img", img_attrs} ->
          src = find_node_attr(img_attrs, "src")
          srcset = find_node_attr(img_attrs, "srcset")
          no_responsive_image = find_node_attr(img_attrs, @no_responsive_image)

          if is_image?(src) && is_nil(srcset) && is_nil(no_responsive_image) do
            add_srcset(input_file, img_attrs)
          else
            {"img", remove_node_attr(img_attrs, @no_responsive_image)}
          end

        other ->
          other
      end)
      |> Floki.raw_html()

    %{source_file | content: new_content}
  end

  def render(source_file), do: source_file

  defp add_srcset(input_file, img_node_attrs) do
    img_html =
      input_file
      |> Path.dirname()
      |> Path.join(find_node_attr(img_node_attrs, "src"))
      |> Path.expand(get_input_path())
      |> get_relative_input_path()
      |> ResponsiveImage.render()

    [src] =
      img_html
      |> Floki.attribute("img", "src")

    [srcset] =
      img_html
      |> Floki.attribute("img", "srcset")

    {"img",
     img_node_attrs
     |> Enum.map(fn
       {"src", _} -> {"src", src}
       other -> other
     end)
     |> Enum.concat([{"srcset", srcset}])}
  end

  defp remove_node_attr(all_attrs, attr) do
    all_attrs
    |> Enum.reject(fn {key, _} -> key == attr end)
  end

  defp find_node_attr(all_attrs, attr) do
    all_attrs
    |> Enum.find(fn {key, _} -> key == attr end)
    |> case do
      {_, val} -> val
      _ -> nil
    end
  end

  defp is_image?(src) do
    String.ends_with?(src, "png") || String.ends_with?(src, "jpeg") ||
      String.ends_with?(src, "jpg")
  end
end
