defmodule Still.Compiler.File.ContentTest do
  use Still.Case, async: false

  alias Still.Compiler.File.Content
  alias Still.Compiler.PreprocessorError
  alias Still.SourceFile

  @preprocessors [
    Still.Preprocessor.Frontmatter,
    Still.Preprocessor.Slime
  ]

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

    test "raises a Compiler.PreprocessorError" do
      file = "index.slime"

      content = """
      ---
      layout: _layout.slime
      ---
      p = test("args")
      """

      assert_raise PreprocessorError, "undefined function test/1", fn ->
        %SourceFile{input_file: file, content: content}
        |> Content.compile(@preprocessors)
      end
    end
  end
end
