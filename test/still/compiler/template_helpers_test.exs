defmodule Still.Compiler.TemplateHelpersTest do
  use Still.Case, async: false

  alias Still.Compiler.TemplateHelpers

  defmodule Template do
    use TemplateHelpers, input_file: "about.slime", dependency_chain: []
  end

  describe "include/2" do
    test "renders a file" do
      file = "_includes/header.slime"

      assert "<header><p>This is a header</p></header>" == Template.include(file)
    end

    test "metadata can be a map or a keyword list" do
      file = "_includes/metadata.slime"

      assert "<nav>This include has metadata: Test</nav>" ==
               Template.include(file, variable: "Test")

      assert "<nav>This include has metadata: Test</nav>" ==
               Template.include(file, %{variable: "Test"})
    end

    test "adds a subscription to the included file" do
      file = "_includes/header.slime"

      Template.include(file)

      assert_receive {_, {:add_subscription, ^file}}, 200
    end
  end
end
