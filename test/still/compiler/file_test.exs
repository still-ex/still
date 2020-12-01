defmodule Still.Compiler.FileTest do
  use Still.Case

  alias Still.Compiler

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

      content = Compiler.File.render(file, %{})

      assert %{
               content: "<header><p>This is a header</p></header>",
               input_file: ^file,
               variables: %{title: "Test title"}
             } = content
    end
  end
end
