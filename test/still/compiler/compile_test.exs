defmodule Still.Compiler.CompileTest do
  use Still.Case

  alias Still.Compiler.Compile

  alias Still.Preprocessor.{
    OutputPath,
    AddContent,
    AddLayout,
    Frontmatter,
    Slime,
    Save
  }

  import Mock

  defmodule TestCaller do
    def hook, do: :ok
  end

  setup do
    {:ok, _} = Compile.start_link([])

    Application.put_env(:still, :preprocessors, %{
      ".slime" => [
        AddContent,
        Frontmatter,
        Slime,
        AddLayout,
        OutputPath,
        Save
      ]
    })

    :ok
  end

  describe "run/0" do
    test "compiles the site" do
      file_path = Still.Utils.get_output_path("index.html")

      refute File.exists?(file_path)

      Compile.run()

      assert File.exists?(file_path)
    end

    test_with_mock "calls the on_compile callbacks", TestCaller, hook: fn -> :ok end do
      Compile.on_compile(&TestCaller.hook/0)
      Compile.run()

      assert_called(TestCaller.hook())
    end
  end
end
