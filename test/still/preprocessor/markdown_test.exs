defmodule Still.Preprocessor.MarkdownTest do
  use ExUnit.Case, async: false

  alias Still.Preprocessor.Markdown
  alias Still.SourceFile

  describe "render/1" do
    test "doesn't replace images with responsive images when :use_responsive_images is false" do
      Application.put_env(:still, Markdown, use_responsive_images: false)

      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        output_file: "",
        extension: ".md",
        content: """
        # Hello!
        ![some alt](../../logo.jpg)
        """
      }

      %{content: content} = Markdown.render(source_file)

      assert content ==
               "<h1>Hello!</h1><p><img src=\"../../logo.jpg\" alt=\"some alt\" /></p>"
    end

    test "replaces images with responsive images when :use_responsive_images is true" do
      Application.put_env(:still, Markdown, use_responsive_images: true)

      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        output_file: "",
        extension: ".md",
        content: """
        # Hello!
        ![some alt](../../logo.jpg)
        """
      }

      %{content: content} = Markdown.render(source_file)

      assert content ==
               "<h1>Hello!</h1><p><img alt=\"some alt\" src=\"/logo-101780779-3708w.jpg\" srcset=\"/logo-101780779-927w.jpg 927w, /logo-101780779-1854w.jpg 1854w, /logo-101780779-2781w.jpg 2781w, /logo-101780779-3708w.jpg 3708w\" /></p>"
    end
  end
end
