defmodule Extatic.Compiler.FileTest do
  use Extatic.Case

  alias Extatic.{Compiler, Collections}

  setup do
    {:ok, _pid} = Collections.start_link(%{})

    :ok
  end

  describe "compile" do
    test "compiles a file" do
      file = "index.slime"

      Compiler.File.compile(file)

      assert File.exists?(get_output_path("index.html"))
    end
  end

  describe "render" do
    test "renders a file" do
      file = "_includes/header.slime"

      content = Compiler.File.render(file)

      assert "<header><p>This is a header</p></header>" == content
    end
  end
end
