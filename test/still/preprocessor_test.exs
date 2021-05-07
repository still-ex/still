defmodule Still.PreprocessorTest do
  use Still.Case, async: false

  alias Still.{Preprocessor, SourceFile, Compiler.PreprocessorError}

  alias Still.Preprocessor.{
    EEx,
    CSSMinify,
    OutputPath,
    AddContent,
    AddLayout,
    Frontmatter,
    Slime,
    Save,
    Profiler
  }

  setup do
    Application.put_env(:still, :preprocessors, %{
      ".slime" => [
        AddContent,
        Frontmatter,
        Slime,
        AddLayout,
        OutputPath,
        Save
      ]
    })

    :ok
  end

  defmodule TestPreprocessorWithExt do
    use Preprocessor

    def render(source_file) do
      %{source_file | extension: ".css"}
    end
  end

  defmodule TestPreprocessorWithoutExt do
    use Preprocessor

    def render(source_file) do
      source_file
    end
  end

  defmodule TestPreprocessorWithCont do
    use Preprocessor

    def render(source_file) do
      {:cont, source_file}
    end
  end

  defmodule TestPreprocessorWithHalt do
    use Preprocessor

    def render(source_file) do
      {:halt, source_file}
    end
  end

  describe "for/1" do
    test "returns the preprocessors for a source_file using the file extension" do
      Application.put_env(:still, :preprocessors, %{
        ".css" => [
          AddContent,
          EEx,
          CSSMinify,
          OutputPath,
          Save
        ]
      })

      assert [Profiler, AddContent, EEx, CSSMinify, OutputPath, Save] ==
               %SourceFile{input_file: "app.css"}
               |> Preprocessor.for()
    end

    test "returns the preprocessors for a source_file using a regex" do
      Application.put_env(:still, :preprocessors, %{
        ~r/^node_tools\/.*\.js/ => [
          AddContent
        ]
      })

      assert [Profiler, AddContent] ==
               %SourceFile{input_file: "node_tools/app.js"}
               |> Preprocessor.for()
    end
  end

  describe "run/1" do
    test "compiles a file" do
      file = "index.slime"
      content = "p Hello"

      assert %{content: "<p>Hello</p>", input_file: ^file} =
               Preprocessor.run(%SourceFile{input_file: file, content: content})
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

      assert %{content: "<p>Hello</p>", metadata: %{hello: "world", tags: ["post", "article"]}} =
               Preprocessor.run(%SourceFile{input_file: file, content: content})
    end

    test "supports layout" do
      file = "index.slime"

      content = """
      ---
      layout: _layout.slime
      ---
      p Hello
      """

      %{content: content} = Preprocessor.run(%SourceFile{input_file: file, content: content})

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

      assert_raise PreprocessorError,
                   ~r/.*\d+\: undefined function test\/1/,
                   fn ->
                     %SourceFile{input_file: file, content: content}
                     |> Preprocessor.run()
                   end
    end
  end

  describe "__using__ run/2" do
    test "sets the extension" do
      %{extension: extension} =
        TestPreprocessorWithExt.run(%SourceFile{content: "", input_file: "test/file.html"})

      assert extension == ".css"
    end

    test "runs the next preprocessors" do
      source_file = %SourceFile{
        input_file: "index.slime",
        content: "p Hello"
      }

      assert %{content: "<p>Hello</p>"} = TestPreprocessorWithCont.run(source_file, [Slime])
    end

    test "doesn't run the next preprocessors" do
      source_file = %SourceFile{
        input_file: "index.slime",
        content: "p Hello"
      }

      assert %{content: "p Hello"} = TestPreprocessorWithHalt.run(source_file, [Slime])
    end

    test "doesn't set the extension" do
      %{extension: extension} =
        TestPreprocessorWithoutExt.run(%SourceFile{content: "", input_file: "test/file.html"})

      assert is_nil(extension)
    end
  end
end
