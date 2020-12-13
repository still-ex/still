defmodule Still.Compiler.Incremental.NodeTest do
  use Still.Case, async: false

  alias Still.Compiler.Incremental.{Registry, Node}

  describe "process" do
    test "compiles a file" do
      pid = Registry.get_or_create_file_process("index.slime")

      Node.compile(pid)

      assert File.exists?(get_output_path("index.html"))
    end

    test "notifies subscribers" do
      file_pid = Registry.get_or_create_file_process("about.slime")
      :erlang.trace(file_pid, true, [:receive])

      other_pid = Registry.get_or_create_file_process("_includes/header.slime")

      Node.render(other_pid, %{}, "about.slime")

      Node.compile(other_pid)

      assert_receive {:trace, ^file_pid, :receive, {:"$gen_call", _, :compile}}, 500
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
