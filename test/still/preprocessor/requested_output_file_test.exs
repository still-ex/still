defmodule Still.Preprocessor.RequestedOutputFileTest do
  alias Still.SourceFile
  alias Still.Preprocessor.RequestedOutputFile

  use Still.Case, async: false

  @input_file "index.html"

  describe "render/1" do
    test "works when :output_file is the same as :requested_output_file" do
      source_file = %SourceFile{
        input_file: @input_file,
        output_file: "index.html",
        requested_output_file: "index.html",
        run_type: :compile_dev
      }

      result = RequestedOutputFile.render(source_file)

      assert result == source_file
    end

    test "fails when :output_file is different from :requested_output_file" do
      source_file = %SourceFile{
        input_file: @input_file,
        output_file: "index.html",
        requested_output_file: "_index.html",
        run_type: :compile_dev
      }

      result = RequestedOutputFile.render(source_file)

      assert result == []
    end

    test "bypasses when the source file doesn't have a :output_file" do
      source_file = %SourceFile{
        input_file: @input_file,
        output_file: nil,
        requested_output_file: "index.html",
        run_type: :compile_dev
      }

      result = RequestedOutputFile.render(source_file)

      assert result == source_file
    end

    test "bypasses when the source file doesn't have a :requested_output_file" do
      source_file = %SourceFile{
        input_file: @input_file,
        output_file: "index.html",
        requested_output_file: nil,
        run_type: :compile_dev
      }

      result = RequestedOutputFile.render(source_file)

      assert result == source_file
    end

    test "bypasses when the source file doesn't have a :run_type :compile_dev" do
      source_file = %SourceFile{
        input_file: @input_file,
        output_file: "index.html",
        requested_output_file: "index.html",
        run_type: :compile_metadata
      }

      result = RequestedOutputFile.render(source_file)

      assert result == source_file
    end
  end
end
