defmodule Still.ProfilerTest do
  use ExUnit.Case, async: true

  alias Still.Profiler
  alias Still.SourceFile

  describe "handle_cast/2 for :register messages" do
    test "saves the source file and the delta" do
      source_file = source_file_fixture()

      {:noreply, state} = Profiler.handle_cast({:register, source_file, 100}, %{})

      assert [%{source_file: ^source_file, delta: 100}] = Map.values(state)
    end

    test "generates different hashes for different files" do
      source_file_1 = source_file_fixture(input_file: "file1.md")
      source_file_2 = source_file_fixture(input_file: "file2.md")

      {:noreply, state} = Profiler.handle_cast({:register, source_file_1, 100}, %{})
      {:noreply, state} = Profiler.handle_cast({:register, source_file_2, 100}, state)

      assert [_, _] = Map.values(state)
    end

    test "generates different hashes for the same file with different metadata" do
      source_file_1 = source_file_fixture(input_file: "file.md", metadata: %{a: 1})
      source_file_2 = source_file_fixture(input_file: "file.md", metadata: %{b: 1})

      {:noreply, state} = Profiler.handle_cast({:register, source_file_1, 100}, %{})
      {:noreply, state} = Profiler.handle_cast({:register, source_file_2, 100}, state)

      assert [_, _] = Map.values(state)
    end

    test "generates equal hashes for functionally equivalent files" do
      source_file_1 = source_file_fixture(input_file: "file.md", metadata: %{a: 1})
      source_file_2 = source_file_fixture(input_file: "file.md", metadata: %{"a" => 1})

      {:noreply, state} = Profiler.handle_cast({:register, source_file_1, 100}, %{})
      {:noreply, state} = Profiler.handle_cast({:register, source_file_2, 100}, state)

      assert [_] = Map.values(state)
    end
  end

  defp source_file_fixture(overrides \\ []) do
    %SourceFile{
      input_file: Keyword.get(overrides, :input_file, "file.md"),
      metadata: Keyword.get(overrides, :metadata, %{layout: "app.html"})
    }
  end
end
