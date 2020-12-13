defmodule Still.Compiler.File.ContentTest do
  use Still.Case, async: false

  alias Still.Compiler.File.Content
  alias Still.Compiler.PreprocessorError
  alias Still.SourceFile
  alias Still.Preprocessor.{Frontmatter, Slime, AddLayout, AddContent}

  @preprocessors [
    AddContent,
    Frontmatter,
    Slime,
    AddLayout
  ]

  describe "compile" do
    test "compiles a file" do
      Application.put_env(:still, :preprocessors, %{
        ".slime" => @preprocessors
      })

      file = "index.slime"
      content = "p Hello"

      assert %{content: "<p>Hello</p>", input_file: file} =
               Content.compile(%SourceFile{input_file: file, content: content})
    end

    test "returns the metadata" do
      Application.put_env(:still, :preprocessors, %{
        ".slime" => @preprocessors
      })

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
               Content.compile(%SourceFile{input_file: file, content: content})
    end

    test "supports layout" do
      Application.put_env(:still, :preprocessors, %{
        ".slime" => @preprocessors
      })

      file = "index.slime"

      content = """
      ---
      layout: _layout.slime
      ---
      p Hello
      """

      %{content: content} = Content.compile(%SourceFile{input_file: file, content: content})

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
