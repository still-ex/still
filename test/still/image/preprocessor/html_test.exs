defmodule Still.Image.Preprocessor.HtmlTest do
  use ExUnit.Case, async: true

  alias Still.Image.Preprocessor.Html
  alias Still.SourceFile

  describe "render/1" do
    test "replaces images with responsive images" do
      source_file = %SourceFile{
        input_file: "blog/index.html",
        output_file: "",
        extension: ".html",
        content: """
        <img src="../logo.jpg" />
        <img alt="some text" src="../logo.jpg" />
        """
      }

      %{content: content} = Html.render(source_file)

      assert content ==
               "<img src=\"/logo-101780779-3708w.jpg\" srcset=\"/logo-101780779-927w.jpg 927w, /logo-101780779-1854w.jpg 1854w, /logo-101780779-2781w.jpg 2781w, /logo-101780779-3708w.jpg 3708w\"/><img alt=\"some text\" src=\"/logo-101780779-3708w.jpg\" srcset=\"/logo-101780779-927w.jpg 927w, /logo-101780779-1854w.jpg 1854w, /logo-101780779-2781w.jpg 2781w, /logo-101780779-3708w.jpg 3708w\"/>"
    end

    test "ignores images with a no-responsive-image attribute" do
      source_file = %SourceFile{
        input_file: "blog/index.html",
        output_file: "",
        extension: ".html",
        content: """
        <img no-responsive-image src="../logo.jpg" />
        <img alt="some text" src="../logo.jpg" />
        """
      }

      %{content: content} = Html.render(source_file)

      assert content ==
               "<img src=\"../logo.jpg\"/><img alt=\"some text\" src=\"/logo-101780779-3708w.jpg\" srcset=\"/logo-101780779-927w.jpg 927w, /logo-101780779-1854w.jpg 1854w, /logo-101780779-2781w.jpg 2781w, /logo-101780779-3708w.jpg 3708w\"/>"
    end
  end
end
