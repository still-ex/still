defmodule Extatic.FileProcessTest do
  use Extatic.Case

  alias Extatic.{FileProcess, Collections, FileRegistry}

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = FileRegistry.start_link(%{})

    :ok
  end

  describe "process" do
    test "compiles a file" do
      {:ok, pid} = FileProcess.start_link(file: "index.slime")

      FileProcess.compile(pid)

      assert File.exists?(get_output_path("index.html"))
    end

    test "notifies subscribers" do
      Process.register(self(), :"about.slime")
      {:ok, pid} = FileProcess.start_link(file: "_includes/header.slime")
      FileProcess.render(pid, %{}, "about.slime")

      FileProcess.compile(pid)

      assert_receive {_, :compile}
    end
  end

  describe "render" do
    test "renders a file" do
      {:ok, pid} = FileProcess.start_link(file: "_includes/header.slime")

      content = FileProcess.render(pid, %{}, "about.slime")

      assert {:ok, "<header><p>This is a header</p></header>", _} = content
    end
  end
end
