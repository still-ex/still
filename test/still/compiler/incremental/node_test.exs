defmodule Still.Compiler.Incremental.NodeTest do
  use Still.Case

  alias Still.Compiler.Collections
  alias Still.Compiler.Incremental.{Registry, Node}
  alias Still.Compiler.CompilationStage

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = Registry.start_link(%{})
    {:ok, _pid} = CompilationStage.start_link(%{})

    :ok
  end

  describe "process" do
    test "compiles a file" do
      {:ok, pid} = Node.start_link(file: "index.slime")

      Node.compile(pid)

      assert File.exists?(get_output_path("index.html"))
    end

    test "notifies subscribers" do
      Process.register(self(), :"about.slime")
      {:ok, pid} = Node.start_link(file: "_includes/header.slime")
      Node.render(pid, %{}, "about.slime")

      Node.compile(pid)

      assert_receive {_, _, :compile}, 200
    end
  end

  describe "render" do
    test "renders a file" do
      {:ok, pid} = Node.start_link(file: "_includes/header.slime")

      content = Node.render(pid, %{}, "about.slime")

      assert %{content: "<header><p>This is a header</p></header>"} = content
    end
  end
end
