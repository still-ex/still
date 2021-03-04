defmodule Still.Compiler.TemplateHelpers.ContentTagTest do
  use ExUnit.Case, async: true

  alias Still.Compiler.TemplateHelpers.ContentTag

  describe "render/3" do
    test "returns the HTML for an image" do
      assert ContentTag.render("img", nil, [
               {:src, "https://gabrielpoca.com/bg.jpg"},
               {:class, "cover"}
             ]) ==
               "<img src=\"https://gabrielpoca.com/bg.jpg\" class=\"cover\"/>"
    end

    test "returns the HTML for an anchor" do
      assert ContentTag.render("a", "My Link", [{:href, "https://gabrielpoca.com"}]) ==
               "<a href=\"https://gabrielpoca.com\">My Link</a>"
    end
  end
end
