defmodule Still.Image.TemplateHelpersTest do
  use Still.Case, async: false

  import Still.Utils

  alias Still.Image.TemplateHelpers

  setup do
    Application.put_env(:still, :base_url, "")

    :ok
  end

  describe "render_src/1" do
    test "returns the src for the biggest output file" do
      src =
        TemplateHelpers.get_output_files("img/bg.jpg")
        |> TemplateHelpers.render_src()

      assert src == "/img/bg-79356388-4692w.jpg"
    end
  end

  describe "render_srcset/1" do
    test "returns the src for the biggest output file" do
      src =
        TemplateHelpers.get_output_files("img/bg.jpg")
        |> TemplateHelpers.render_srcset()

      assert src ==
               "/img/bg-79356388-1173w.jpg 1173w, /img/bg-79356388-2346w.jpg 2346w, /img/bg-79356388-3519w.jpg 3519w, /img/bg-79356388-4692w.jpg 4692w"
    end
  end

  describe "render/3" do
    test "returns the HTML for a responsive image" do
      file = "img/bg.jpg"

      {:ok, %{width: width}} = file |> get_input_path() |> get_image_info()

      half_width = Integer.floor_div(width, 2)

      output =
        TemplateHelpers.render_html(
          file,
          class: "cover",
          sizes: [width, half_width],
          transformations: []
        )

      src = "/img/bg-14881671-#{width}w.jpg"

      srcset =
        "/img/bg-14881671-#{half_width}w.jpg #{half_width}w, /img/bg-14881671-#{width}w.jpg #{
          width
        }w"

      assert output ==
               "<img src=\"#{src}\" srcset=\"#{srcset}\" class=\"cover\"/>"
    end

    test "uses the default configuration" do
      output = TemplateHelpers.render_html("img/bg.jpg")

      assert output ==
               "<img src=\"/img/bg-79356388-4692w.jpg\" srcset=\"/img/bg-79356388-1173w.jpg 1173w, /img/bg-79356388-2346w.jpg 2346w, /img/bg-79356388-3519w.jpg 3519w, /img/bg-79356388-4692w.jpg 4692w\"/>"
    end
  end
end
