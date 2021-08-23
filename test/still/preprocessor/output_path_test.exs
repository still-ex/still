defmodule Still.Preprocessor.OutputPathTest do
  use Still.Case, async: false

  alias Still.Preprocessor.OutputPath

  describe "render/1" do
    test "handles files with two extensions" do
      source_file = %{input_file: "music.eex.html", extension: ".html", output_file: nil}

      source_file = OutputPath.render(source_file)

      assert source_file[:output_file] == "music.html"
    end
  end
end
