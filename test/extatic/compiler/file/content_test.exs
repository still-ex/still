defmodule Extatic.Compiler.File.ContentTest do
  use ExUnit.Case, async: true

  alias Extatic.Compiler.File.Content
  alias Extatic.{Collections, FileRegistry}

  @preprocessor Extatic.Compiler.Preprocessor.Slime

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = FileRegistry.start_link(%{})

    :ok
  end

  describe "compile " do
    test "compiles a file" do
      file = "index.slime"
      content = "p Hello"

      assert {:ok, "<p>Hello</p>", %{file_path: file}} =
               Content.compile(file, content, @preprocessor)
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
               Content.compile(file, content, @preprocessor)
    end

    test "supports layout" do
      file = "index.slime"

      content = """
      ---
      layout: _layout.slime
      ---
      p Hello
      """

      {:ok, content, _} = Content.compile(file, content, @preprocessor)

      assert String.starts_with?(content, "<!DOCTYPE html><html><head><title>Extatic</title>")
      assert String.ends_with?(content, "<body><p>Hello</p></body></html>")
    end
  end
end
