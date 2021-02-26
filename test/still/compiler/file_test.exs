defmodule Still.Compiler.FileTest do
  use Still.Case, async: false

  alias Still.{Compiler, SourceFile}
  alias Still.Preprocessor.{Frontmatter, Slime, OutputPath, Save, AddContent}

  setup do
    Application.put_env(:still, :preprocessors, %{
      ".slime" => [
        AddContent,
        Frontmatter,
        Slime,
        OutputPath,
        Save
      ]
    })

    :ok
  end

  describe "compile" do
    test "compiles a slime template" do
      file = "index.slime"

      Compiler.File.compile(file)

      assert File.exists?(get_output_path("index.html"))
    end
  end

  describe "render" do
    test "renders a slime template" do
      file = "_includes/header.slime"

      content = Compiler.File.render(%SourceFile{input_file: file, dependency_chain: [file]})

      assert %{
               content: "<header><p>This is a header</p></header>",
               input_file: ^file,
               metadata: %{title: "Test title"}
             } = content
    end
  end
end
