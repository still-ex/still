defmodule Still.Compiler.Incremental.NodeTest do
  use Still.Case, async: false

  alias Still.SourceFile
  alias Still.Preprocessor
  alias Still.Compiler.Incremental
  alias Still.Compiler.Incremental.Node
  alias Still.Preprocessor.{Frontmatter, Slime, AddLayout, AddContent, Save, OutputPath}
  alias Still.Compiler.Incremental.OutputToInputFileRegistry

  import Mock
  import Still.Utils

  @preprocessors [
    AddContent,
    Frontmatter,
    Slime,
    AddLayout,
    OutputPath,
    Save
  ]

  setup do
    Application.put_env(:still, :preprocessors, %{
      ".slime" => @preprocessors
    })

    :ok
  end

  describe "compile" do
    test "compiles a file" do
      pid = Incremental.Registry.get_or_create_file_process("about.slime")

      Node.compile(pid)

      assert File.exists?(get_output_path("about.html"))
    end

    test "doesn't recompile file when [use_cache: true] is passed in the opts" do
      input_file = "about.slime"
      pid = Incremental.Registry.get_or_create_file_process(input_file)

      source_file = %SourceFile{
        input_file: input_file,
        dependency_chain: [input_file],
        run_type: :compile
      }

      Node.compile(pid)

      with_mock(Preprocessor, run: fn _ -> [%{source_file | output_file: "about.html"}] end) do
        Node.compile(pid, use_cache: true)

        refute called(Preprocessor.run(source_file))
      end
    end

    test "registers the file in OutputToInputFileRegistry" do
      pid = Incremental.Registry.get_or_create_file_process("about.slime")

      Node.compile(pid)

      response = OutputToInputFileRegistry.lookup(get_output_path("about.html"))
      assert [{_, "about.slime"}] = response
    end
  end

  describe "render" do
    test "renders a file" do
      pid = Incremental.Registry.get_or_create_file_process("_includes/header.slime")

      content = Node.render(pid, %{dependency_chain: ["about.slime"]}) |> hd()

      assert %{content: "<header><p>This is a header</p></header>"} = content
    end
  end
end
