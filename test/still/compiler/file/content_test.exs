defmodule Still.Compiler.File.ContentTest do
  use ExUnit.Case, async: true

  alias Still.Compiler.{Collections, File.Content, Incremental}

  @preprocessors [
    Still.Preprocessor.Frontmatter,
    Still.Preprocessor.Slime
  ]

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = Incremental.Registry.start_link(%{})

    :ok
  end

  describe "compile" do
    test "compiles a file" do
      file = "index.slime"
      content = "p Hello"

      assert {:ok, "<p>Hello</p>", %{file_path: file}} =
               Content.compile(file, content, @preprocessors)
    end

    test "returns the metadata" do
      file = "index.slime"

      content = """
      ---
      hello: world
      tags:
        - post
        - article
      ---
      p Hello
      """

      assert {:ok, "<p>Hello</p>", %{hello: "world", tags: ["post", "article"]}} =
               Content.compile(file, content, @preprocessors)
    end

    test "supports layout" do
      file = "index.slime"

      content = """
      ---
      layout: _layout.slime
      ---
      p Hello
      """

      {:ok, content, _} = Content.compile(file, content, @preprocessors)

      assert String.starts_with?(content, "<!DOCTYPE html><html><head><title>Still</title>")
      assert String.ends_with?(content, "<body><p>Hello</p></body></html>")
    end
  end
end
