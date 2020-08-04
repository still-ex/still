defmodule Extatic.FileRegistryTest do
  use ExUnit.Case, async: true
  alias Extatic.FileRegistry

  setup do
    {:ok, _pid} = FileRegistry.start_link(%{})
    {:ok, _pid} = FileRegistry.Supervisor.start_link(%{})

    :ok
  end

  describe "get" do
    test "returns the pid of a file process" do
      assert {:ok, _pid} = FileRegistry.get("index.slime")
    end
  end

  describe "get_and_subscribe" do
    test "returns the pid of a file process and adds it to the calling process's subscriptions" do
      {:ok, pid} = FileRegistry.get_and_subscribe("index.slime")

      subsriptions = FileRegistry.subscriptions()

      assert get_in(subsriptions, [self()]) == [pid]
    end
  end

  describe "clear_subscriptions" do
    test "clears the subscriptions for the calling process" do
      {:ok, _} = FileRegistry.get_and_subscribe("index.slime")

      FileRegistry.clear_subscriptions()
      subsriptions = FileRegistry.subscriptions()

      assert get_in(subsriptions, [self()]) == []
    end
  end
end
