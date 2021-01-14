defmodule Still.Compiler.ViewHelpers.SafeHTMLTest do
  use ExUnit.Case, async: true

  alias Still.Compiler.ViewHelpers.SafeHTML

  describe "render/1" do
    test "renders nil" do
      assert "" == SafeHTML.render(nil)
    end

    test "HTML escapes atoms" do
      assert "foo" = SafeHTML.render(:foo)
      assert "&lt;h1&gt;" = SafeHTML.render(:"<h1>")
    end

    test "HTML escapes strings" do
      assert "foo" = SafeHTML.render("foo")
      assert "&lt;h1&gt;" = SafeHTML.render("<h1>")
    end

    test "HTML escapes lists" do
      list = [:foo, "<h1>", ~D[2021-01-01]]

      assert "foo, &lt;h1&gt;, 2021-01-01" = SafeHTML.render(list)
    end

    test "converts integers to strings" do
      assert "1" = SafeHTML.render(1)
    end

    test "converts floats to strings" do
      assert "1.0" = SafeHTML.render(1.0)
    end

    test "renders dates" do
      assert "2021-01-01" = SafeHTML.render(~D[2021-01-01])
    end

    test "renders times" do
      assert "12:00:00" = SafeHTML.render(~T[12:00:00])
    end

    test "renders naive date times" do
      assert "2021-01-01 12:00:00" = SafeHTML.render(~N[2021-01-01 12:00:00])
    end

    test "renders date times" do
      dt = DateTime.from_naive!(~N[2021-01-01 12:00:00], "Etc/UTC")

      assert "2021-01-01 12:00:00Z" = SafeHTML.render(dt)
    end

    test "renders data marked as safe" do
      assert "<h1>" = SafeHTML.render({:safe, "<h1>"})
    end

    test "raises errors on unsupported data" do
      assert_raise ArgumentError, fn ->
        SafeHTML.render({"h1", "title"})
      end

      assert_raise ArgumentError, fn ->
        SafeHTML.render(%{"h1" => "title"})
      end
    end
  end
end
