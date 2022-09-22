defmodule Still.Compiler.ErrorCacheTest do
  use Still.Case, async: false

  alias Still.Compiler.{ErrorCache, PreprocessorError}
  alias Still.SourceFile

  describe "set/1 with an error" do
    test "sets the given error" do
      error = %PreprocessorError{
        payload: :udnef,
        kind: :error,
        source_file: %SourceFile{
          input_file: "_header.slime",
          dependency_chain: ["_header.slime", "index.slime"]
        }
      }

      ErrorCache.set({:error, error})

      errors = ErrorCache.get_errors()

      assert not is_nil(errors["_header.slime <- index.slime"])
    end
  end

  describe "set/1 without an error" do
    test "doesn't set an error" do
      source_file = %SourceFile{
        input_file: "_header.slime",
        dependency_chain: ["_header.slime", "index.slime"]
      }

      ErrorCache.set({:ok, source_file})

      errors = ErrorCache.get_errors()

      assert is_nil(errors["index.slime <- _header.slime"])
    end

    test "removes errors for the given file" do
      source_file = %SourceFile{
        input_file: "_header.slime",
        dependency_chain: ["_header.slime", "index.slime"]
      }

      error = %PreprocessorError{source_file: source_file}
      ErrorCache.set({:error, error})

      source_file = %SourceFile{
        input_file: "_header.slime",
        dependency_chain: ["_header.slime", "about.slime"]
      }

      error = %PreprocessorError{source_file: source_file}
      ErrorCache.set({:error, error})

      ErrorCache.set({:ok, source_file})

      errors = ErrorCache.get_errors()

      assert is_nil(errors["_header.slime <- index.slime"])
      assert is_nil(errors["_header.slime <- about.slime"])
    end

    test "recompiles initial files for existing errors of the same file" do
      source_file = %SourceFile{
        input_file: "_header.slime",
        dependency_chain: ["_header.slime", "now.slime"]
      }

      error = %PreprocessorError{source_file: source_file}
      ErrorCache.set({:error, error})

      Process.register(self(), :"now.slime")

      ErrorCache.set({:ok, source_file})

      assert_receive {_, _, {:compile_metadata, _}}
    end
  end
end
