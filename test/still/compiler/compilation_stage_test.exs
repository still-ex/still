defmodule Still.Compiler.CompilationStageTest do
  use Still.Case

  alias Still.Compiler.CompilationStage

  describe "handle_cast/2 for :on_compile messages" do
    test "saves the hook" do
      mfa = {Kernel, :node, []}
      captured_fun = &Kernel.node/0
      anon_fun = fn -> Kernel.node() end

      state_0 = %{hooks: []}

      assert {:noreply, state_1} = CompilationStage.handle_cast({:on_compile, mfa}, state_0)

      assert {:noreply, state_2} =
               CompilationStage.handle_cast({:on_compile, captured_fun}, state_1)

      assert {:noreply, state_3} = CompilationStage.handle_cast({:on_compile, anon_fun}, state_2)

      assert %{hooks: [_, _, _]} = state_3
    end

    test "requires unique hooks" do
      mfa = {Kernel, :node, []}
      state_0 = %{hooks: []}

      assert {:noreply, state_1} = CompilationStage.handle_cast({:on_compile, mfa}, state_0)
      assert {:noreply, state_2} = CompilationStage.handle_cast({:on_compile, mfa}, state_1)

      assert %{hooks: [_]} = state_2
    end
  end

  describe "handle_info/2 for :notify_subscribers messages when :to_compile is empty" do
    test "calls the saved hooks" do
      fun = fn -> send(self(), :called) end
      state = %{hooks: [fun], to_compile: [], subscribers: []}

      CompilationStage.handle_info(:notify_subscribers, state)

      assert_received :called
    end

    test "ignores captured functions with the wrong arity" do
      fun = fn _pid -> send(self(), :called) end
      state = %{hooks: [fun], to_compile: [], subscribers: []}

      CompilationStage.handle_info(:notify_subscribers, state)

      refute_received :called
    end

    test "sends the :bus_empty message to subscribers" do
      state = %{hooks: [], to_compile: [], subscribers: [self()]}

      CompilationStage.handle_info(:notify_subscribers, state)

      assert_received :bus_empty
    end
  end
end
