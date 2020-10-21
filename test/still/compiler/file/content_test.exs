defmodule Still.Compiler.File.ContentTest do
  use ExUnit.Case

  alias Still.Compiler.{Collections, File.Content, Incremental}
  alias Still.SourceFile

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

      assert %{content: "<p>Hello</p>", input_file: file} =
               Content.compile(%SourceFile{input_file: file, content: content}, @preprocessors)
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

      assert %{content: "<p>Hello</p>", variables: %{hello: "world", tags: ["post", "article"]}} =
               Content.compile(%SourceFile{input_file: file, content: content}, @preprocessors)
    end

    test "supports layout" do
      file = "index.slime"

      content = """
      ---
      layout: _layout.slime
      ---
      p Hello
      """

      %{content: content} =
        Content.compile(%SourceFile{input_file: file, content: content}, @preprocessors)

      assert String.starts_with?(content, "<!DOCTYPE html><html><head><title>Still</title>")
      assert String.ends_with?(content, "<body><p>Hello</p></body></html>")
    end
  end
end
