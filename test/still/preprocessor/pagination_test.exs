defmodule Still.Preprocessor.PaginationTest do
  use Still.Case, async: false

  alias Still.Preprocessor.Pagination
  alias Still.SourceFile

  describe "render/1" do
    test "processes pagination data" do
      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        metadata: %{
          pagination: %{
            data: "[1, 2, 3, 4]",
            size: 2
          }
        }
      }

      [page_1, page_2] = Pagination.render(source_file)

      assert page_1.metadata.pagination == %{
               items: [1, 2],
               page_nr: 1,
               pages: [[1, 2], [3, 4]]
             }

      assert page_2.metadata.pagination == %{
               items: [3, 4],
               page_nr: 2,
               pages: [[1, 2], [3, 4]]
             }
    end

    test "takes the :size into account" do
      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        metadata: %{
          pagination: %{
            data: "[1, 2, 3, 4]",
            size: 3
          }
        }
      }

      [page_1, page_2] = Pagination.render(source_file)

      assert page_1.metadata.pagination.items == [1, 2, 3]

      assert page_2.metadata.pagination.items == [4]
    end

    test "treats :data as Elixir" do
      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        metadata: %{
          pagination: %{
            data: "[1, 2, 3, 4] |> Enum.take(2)",
            size: 2
          }
        }
      }

      [page] = Pagination.render(source_file)

      assert page.metadata.pagination.items == [1, 2]
    end

    test "throws an error if the :data doesn't return a list" do
      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        metadata: %{
          pagination: %{
            data: "1",
            size: 2
          }
        }
      }

      assert_raise RuntimeError, "Failed to eval \"1\"", fn ->
        Pagination.render(source_file)
      end
    end

    test "makes the other properties of :metadata available inside :data" do
      source_file = %SourceFile{
        input_file: "blog/posts/index.md",
        metadata: %{
          items: [1, 2, 3],
          pagination: %{
            data: "items",
            size: 2
          }
        }
      }

      [page_1, page_2] = Pagination.render(source_file)

      assert page_1.metadata.pagination.items == [1, 2]
      assert page_2.metadata.pagination.items == [3]
    end
  end
end
