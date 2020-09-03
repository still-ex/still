defmodule Extatic.Compiler.PreprocessorTest do
  use ExUnit.Case, async: true
  alias Extatic.Compiler.Preprocessor

  defmodule TestPreprocessorWithExt do
    use Preprocessor, ext: ".css"

    def render(content, variables) do
      {content, variables}
    end
  end

  defmodule TestPreprocessorWithoutExt do
    use Preprocessor

    def render(content, variables) do
      {content, variables}
    end
  end

  describe "__using__ run/2" do
    test "sets the permalink" do
      {_, variables} = TestPreprocessorWithExt.run("", %{file_path: "test/file.html"})

      assert variables[:permalink] == "test/file.css"
    end

    test "doesn't set the permalink" do
      {_, variables} = TestPreprocessorWithoutExt.run("", %{file_path: "test/file.html"})

      assert is_nil(variables[:permalink])
    end
  end
end
