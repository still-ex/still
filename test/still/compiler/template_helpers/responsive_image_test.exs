defmodule Still.Compiler.TemplateHelpers.ResponsiveImageTest do
  use Still.Case, async: false

  alias Still.Compiler.TemplateHelpers.ResponsiveImage
  alias Still.Utils

  setup do
    Application.put_env(:still, :base_url, "")

    :ok
  end

  describe "render/3" do
    test "returns the HTML for a responsive image" do
      file = "img/bg.jpg"

      {:ok, %{width: width}} = file |> Utils.get_input_path() |> Utils.get_image_info()

      half_width = Integer.floor_div(width, 2)

      output =
        file
        |> ResponsiveImage.render(
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

    test "sets the sizes when not specified by the caller" do
      output =
        "img/bg.jpg"
        |> ResponsiveImage.render()

      assert output ==
               "<img src=\"/img/bg-79356388-4692w.jpg\" srcset=\"/img/bg-79356388-1173w.jpg 1173w, /img/bg-79356388-2346w.jpg 2346w, /img/bg-79356388-3519w.jpg 3519w, /img/bg-79356388-4692w.jpg 4692w\"/>"
    end
  end
end
