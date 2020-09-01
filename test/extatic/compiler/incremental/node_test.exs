defmodule Extatic.Compiler.Incremental.NodeTest do
  use Extatic.Case

  alias Extatic.Compiler.Collections
  alias Extatic.Compiler.Incremental.{Registry, Node}

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = Registry.start_link(%{})

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

      assert_receive {_, _, :compile}
    end
  end

  describe "render" do
    test "renders a file" do
      {:ok, pid} = Node.start_link(file: "_includes/header.slime")

      content = Node.render(pid, %{}, "about.slime")

      assert {:ok, "<header><p>This is a header</p></header>", _} = content
    end
  end
end
