defmodule Still.Preprocessor.SlimeTest do
  use Still.Case, async: false

  alias Still.Preprocessor.Slime
  alias Still.SourceFile

  describe "render" do
    test "compiles a template" do
      slime = "p Still"
      input_file = "index.slime"

      %{content: html} = Slime.render(%SourceFile{content: slime, input_file: input_file})

      assert html == "<p>Still</p>"
    end

    test "passes variables to the template" do
      slime = "p = @title"
      input_file = "index.slime"
      title = "This is a test"

      %{content: html} =
        Slime.render(%SourceFile{
          content: slime,
          input_file: input_file,
          variables: %{title: title}
        })

      assert html == "<p>This is a test</p>"
    end

    test "defines a render module" do
      slime = "p Still"
      input_file = "posts/index.slime"

      Slime.render(%SourceFile{content: slime, input_file: input_file})

      assert {:module, _} =
               Code.ensure_compiled(Still.Preprocessor.Slime.Posts.Index) |> IO.inspect()
    end
  end
end
