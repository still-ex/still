defmodule Still.Compiler.ErrorCacheTest do
  use Still.Case, async: true

  alias Still.Compiler.{ErrorCache, PreprocessorError}
  alias Still.SourceFile

  describe "set/1" do
    test "set an errors for the given" do
      error = %PreprocessorError{
        source_file: %SourceFile{
          input_file: "_header.slime",
          dependency_chain: ["index.eex", "_header.slime"]
        }
      }

      ErrorCache.set({:error, error})

      errors = ErrorCache.get_errors()

      assert not is_nil(errors["index.eex <- _header.slime"])
    end

    test "doesn't set an error for the given file" do
      source_file = %SourceFile{
        input_file: "_header.slime",
        dependency_chain: ["index.eex", "_header.slime"]
      }

      ErrorCache.set({:ok, source_file})

      errors = ErrorCache.get_errors()

      assert is_nil(errors["index.eex <- _header.slime"])
    end

    test "removes an error for the given" do
      source_file = %SourceFile{
        input_file: "_header.slime",
        dependency_chain: ["index.eex", "_header.slime"]
      }

      error = %PreprocessorError{source_file: source_file}

      ErrorCache.set({:error, error})

      ErrorCache.set({:ok, source_file})

      errors = ErrorCache.get_errors()
      assert errors["index.html"] == nil
    end
  end
end
