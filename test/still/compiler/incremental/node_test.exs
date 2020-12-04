defmodule Still.Compiler.Incremental.NodeTest do
  use Still.Case, async: false

  alias Still.Compiler.Collections
  alias Still.Compiler.Incremental.{Registry, Node}
  alias Still.Compiler.CompilationStage

  describe "process" do
    test "compiles a file" do
      pid = Registry.get_or_create_file_process("index.slime")

      Node.compile(pid)

      assert File.exists?(get_output_path("index.html"))
    end

    test "notifies subscribers" do
      Process.register(self(), :"about.slime")

      pid = Registry.get_or_create_file_process("_includes/header.slime")

      Node.render(pid, %{}, "about.slime")

      Node.compile(pid)

      assert_receive {_, _, :compile}, 200
    end
  end

  describe "render" do
    test "renders a file" do
      pid = Registry.get_or_create_file_process("_includes/header.slime")

      content = Node.render(pid, %{}, "about.slime")

      assert %{content: "<header><p>This is a header</p></header>"} = content
    end
  end
end
