defmodule Still.Compiler.CollectionsTest do
  use Still.Case, async: false

  alias Still.{
    Compiler.Collections,
    SourceFile
  }

  describe "get/1" do
    test "retruns the files associated with a given collection" do
      file = %SourceFile{input_file: "file", metadata: %{tag: ["post"]}}

      Collections.add(file)

      assert Collections.get("post") |> length() == 1
    end
  end

  describe "add/1" do
    test "removes the SourceFile's content to save memory" do
      file = %SourceFile{input_file: "file", content: "some content", metadata: %{tag: ["post"]}}

      Collections.add(file)

      refute Collections.get("post") |> hd() |> Map.get(:content)
    end

    test "ignores files that don't have a tag" do
      file = %SourceFile{input_file: "file", content: "some content"}

      Collections.add(file)

      assert Collections.get("post") |> length() == 0
    end
  end
end
