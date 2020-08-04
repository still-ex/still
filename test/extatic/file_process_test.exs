defmodule Extatic.FileProcessTest do
  use Extatic.Case

  alias Extatic.{FileProcess, Collections}

  setup do
    {:ok, _pid} = Collections.start_link(%{})

    :ok
  end

  describe "process" do
    test "compiles a file" do
      {:ok, pid} = FileProcess.start_link(%{file: "index.slime" |> String.to_atom()})

      FileProcess.compile(pid)

      assert File.exists?(get_output_path("index.html"))
    end
  end

  describe "render" do
    test "renders a file" do
      {:ok, pid} = FileProcess.start_link(%{file: "_includes/header.slime" |> String.to_atom()})

      content = FileProcess.render(pid)

      assert "<header><p>This is a header</p></header>" == content
    end
  end
end
