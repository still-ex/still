defmodule Extatic.Compiler.Preprocessor.SlimeTest do
  use Extatic.Case

  alias Extatic.Compiler.Preprocessor.Slime

  describe "render" do
    test "compiles a template" do
      slime = "p Extatic"
      file_path = "index.slime"

      {html, _} = Slime.render(slime, %{file_path: file_path})

      assert html == "<p>Extatic</p>"
    end

    test "passes variables to the template" do
      slime = "p = title"
      file_path = "index.slime"
      title = "This is a test"

      {html, _} = Slime.render(slime, %{file_path: file_path, title: title})

      assert html == "<p>This is a test</p>"
    end

    test "defines a render module" do
      slime = "p Extatic"
      file_path = "posts/index.slime"

      Slime.render(slime, %{file_path: file_path})

      assert {:module, _} = Code.ensure_compiled(Extatic.Compiler.Preprocessor.Slime.Posts.Index)
    end
  end
end
