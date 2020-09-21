defmodule Still.Compiler.FileTest do
  use Still.Case

  alias Still.{Compiler, Compiler.Incremental, Compiler.Collections}

  setup do
    {:ok, _pid} = Collections.start_link(%{})
    {:ok, _pid} = Incremental.Registry.start_link(%{})

    :ok
  end

  describe "compile" do
    test "compiles a slime template" do
      file = "index.slime"

      Compiler.File.compile(file)

      assert File.exists?(get_output_path("index.html"))
    end
  end

  describe "render" do
    test "renders a slime template" do
      file = "_includes/header.slime"

      content = Compiler.File.render(file, %{})

      assert {:ok, "<header><p>This is a header</p></header>", %{file_path: ^file}} = content
    end
  end
end
