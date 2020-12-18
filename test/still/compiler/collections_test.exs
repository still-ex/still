defmodule Still.Compiler.CollectionsTest do
  use Still.Case, async: false

  import Mock

  alias Still.{
    Compiler.Collections,
    SourceFile,
    Compiler.Incremental.Registry
  }

  describe "get/2" do
    test "retruns the files associated with a given collection" do
      file = %SourceFile{input_file: "file", metadata: %{tag: ["post"]}}

      Collections.add(file)

      assert Collections.get("post", "file") |> length() == 1
    end

    test "subscribes for changes to the given collection" do
      file_pid = Registry.get_or_create_file_process("about.slime")
      :erlang.trace(file_pid, true, [:receive])

      with_mock Registry, get_or_create_file_process: fn _ -> file_pid end do
        file = %SourceFile{input_file: "file", metadata: %{tag: ["post"]}}
        Collections.add(file)
        Collections.get("post", "about.slime")

        Collections.add(file)

        assert_receive {:trace, ^file_pid, :receive, {:"$gen_call", _, :compile}}, 500
      end
    end
  end
end
