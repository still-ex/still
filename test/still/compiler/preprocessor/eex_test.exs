defmodule Still.Preprocessor.EExTest do
  use Still.Case, async: false

  alias Still.Preprocessor.EEx
  alias Still.SourceFile

  describe "render" do
    test "compiles a template" do
      eex = "<p>Still</p>"
      input_file = "index.eex"

      %{content: html} = EEx.render(%SourceFile{content: eex, input_file: input_file})

      assert html == "<p>Still</p>"
    end

    test "passes metadata to the template" do
      eex = "<p><%= @title %></p>"
      input_file = "index.eex"
      title = "This is a test"

      %{content: html} =
        EEx.render(%SourceFile{
          content: eex,
          input_file: input_file,
          metadata: %{title: title}
        })

      assert html == "<p>This is a test</p>"
    end
  end
end
