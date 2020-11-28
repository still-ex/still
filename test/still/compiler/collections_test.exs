defmodule Still.Compiler.CollectionsTest do
  use ExUnit.Case

  import Mock

  alias Still.{
    Compiler.Collections,
    SourceFile,
    Compiler.Incremental.Registry,
    Compiler.CompilationQueue
  }

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = CompilationQueue.start_link(%{})

    :ok
  end

  describe "get/2" do
    test "retruns the files associated with a given collection" do
      file = %SourceFile{input_file: "file", variables: %{tag: ["post"]}}

      Collections.add(file)

      assert Collections.get("post", "file") |> length() == 1
    end

    test "subscribes for changes to the given collection" do
      pid = self()

      with_mock Registry, get_or_create_file_process: fn _ -> pid end do
        file = %SourceFile{input_file: "file", variables: %{tag: ["post"]}}
        Collections.add(file)
        Collections.get("post", "file")

        Collections.add(file)

        assert_receive {_, _, :compile}, 200
      end
    end
  end
end
