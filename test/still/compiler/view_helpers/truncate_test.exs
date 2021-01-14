defmodule Still.Compiler.ViewHelpers.TruncateTest do
  use ExUnit.Case, async: true

  alias Still.Compiler.ViewHelpers.Truncate

  describe "render/2" do
    test "truncates to the correct length" do
      str = Stream.repeatedly(fn -> "a" end) |> Stream.take(301) |> Enum.join()

      result = Truncate.render(str)

      assert result =~ ~r/^a{297}\.\.\.$/
    end

    test "supports a :length option" do
      str = Stream.repeatedly(fn -> "a" end) |> Stream.take(301) |> Enum.join()

      result = Truncate.render(str, length: 200)

      assert result =~ ~r/^a{197}\.\.\.$/
    end

    test "does not slice strings larger than :length when truncated" do
      str = "aa"

      assert ^str = Truncate.render(str, length: 1)
    end

    test "supports an :omission option" do
      str = Stream.repeatedly(fn -> "a" end) |> Stream.take(301) |> Enum.join()

      result = Truncate.render(str, omission: "???")

      assert result =~ ~r/^a{297}\?\?\?$/
    end

    test "ignores strings smaller than :length" do
      str = "a"

      assert ^str = Truncate.render(str, length: 2)
    end
  end
end
