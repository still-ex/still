defmodule Still.PreprocessorTest do
  use ExUnit.Case

  alias Still.{Preprocessor, SourceFile}

  defmodule TestPreprocessorWithExt do
    use Preprocessor

    def extension(_) do
      ".css"
    end

    def render(file) do
      file
    end
  end

  defmodule TestPreprocessorWithoutExt do
    use Preprocessor

    def render(file) do
      file
    end
  end

  describe "__using__ run/2" do
    test "sets the extension" do
      %{extension: extension} =
        TestPreprocessorWithExt.run(%SourceFile{content: "", input_file: "test/file.html"})

      assert extension == ".css"
    end

    test "doesn't set the extension" do
      %{extension: extension} =
        TestPreprocessorWithoutExt.run(%SourceFile{content: "", input_file: "test/file.html"})

      assert is_nil(extension)
    end
  end
end
