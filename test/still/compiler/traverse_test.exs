defmodule Still.Compiler.TraverseTest do
  use Still.Case, async: false

  alias Still.Compiler.Traverse

  import Mock

  defmodule TestCallback do
    def callback(_file) do
    end
  end

  describe "run/1" do
    test_with_mock "calls the given callback", TestCallback, callback: fn _ -> :ok end do
      Traverse.run(&TestCallback.callback/1)

      assert_called(TestCallback.callback("index.slime"))
      assert_called(TestCallback.callback("img/bg.jpg"))
      assert_called(TestCallback.callback("css/theme.css"))
    end
  end
end
