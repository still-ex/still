defmodule Still.Compiler.ViewHelpersTest do
  use Still.Case, async: false

  alias Still.Compiler.ViewHelpers

  defmodule View do
    use ViewHelpers
  end

  describe "include/2" do
    test "renders a file" do
      file = "_includes/header.slime"

      assert "<header><p>This is a header</p></header>" == View.include(file)
    end

    test "variables can be a map or a keyword list" do
      file = "_includes/variables.slime"

      assert "<nav>This include has variables: Test</nav>" == View.include(file, variable: "Test")

      assert "<nav>This include has variables: Test</nav>" ==
               View.include(file, %{variable: "Test"})
    end

    test "adds a subscription to the included file" do
      file = "_includes/header.slime"

      View.include(file)

      assert_receive {_, {:add_subscription, file}}
    end
  end
end
