defmodule Still.Compiler.CollectionsTest do
  use Still.Case, async: false

  alias Still.{
    Compiler.Collections,
    SourceFile
  }

  describe "get/2" do
    test "retruns the files associated with a given collection" do
      file = %SourceFile{input_file: "file", metadata: %{tags: ["post"]}}

      Collections.add(file)

      assert Collections.get("post") |> length() == 1
    end
  end
end
