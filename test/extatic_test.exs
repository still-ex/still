defmodule ExtaticTest do
  use ExUnit.Case
  doctest Extatic

  test "greets the world" do
    assert Extatic.hello() == :world
  end
end
