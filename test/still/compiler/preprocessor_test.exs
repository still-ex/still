defmodule Still.PreprocessorTest do
  use ExUnit.Case, async: true
  alias Still.Preprocessor

  defmodule TestPreprocessorWithExt do
    use Preprocessor, ext: ".css"

    def render(content, variables) do
      %{content: content, variables: variables}
    end
  end

  defmodule TestPreprocessorWithoutExt do
    use Preprocessor

    def render(content, variables) do
      %{content: content, variables: variables}
    end
  end

  describe "__using__ run/2" do
    test "sets the extension" do
      %{variables: variables} = TestPreprocessorWithExt.run("", %{file_path: "test/file.html"})

      assert variables[:extension] == ".css"
    end

    test "doesn't set the extension" do
      %{variables: variables} = TestPreprocessorWithoutExt.run("", %{file_path: "test/file.html"})

      assert is_nil(variables[:extension])
    end
  end
end
