defmodule Still.Compiler.TemplateHelpersTest do
  use Still.Case, async: false

  alias Still.Compiler.TemplateHelpers

  @env [input_file: "about.slime", dependency_chain: []]

  describe "include/2" do
    test "renders a file" do
      file = "_includes/header.slime"

      assert "<header><p>This is a header</p></header>" == TemplateHelpers.include(@env, file)
    end

    test "raises when the included file does not exist" do
      file = "_includes/file_does_not_exist.slime"

      assert_raise RuntimeError,
                   ~r/File _includes\/file_does_not_exist.slime does not exist in.*/,
                   fn ->
                     TemplateHelpers.include(@env, file)
                   end
    end

    test "metadata can be a map or a keyword list" do
      file = "_includes/metadata.slime"

      assert "<nav>This include has metadata: Test</nav>" ==
               TemplateHelpers.include(@env, file, variable: "Test")

      assert "<nav>This include has metadata: Test</nav>" ==
               TemplateHelpers.include(@env, file, %{variable: "Test"})
    end
  end
end
