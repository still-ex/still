defmodule Still.Preprocessor.ImageTest do
  use Still.Case, async: false

  alias Still.Preprocessor.Image
  alias Still.SourceFile

  @input_file "img/bg.jpg"
  @output_file "img/bg.jpg"
  @output_file_100 "img/bg-111931420-100w.jpg"
  @output_file_200 "img/bg-111931420-200w.jpg"

  describe "render/1" do
    test "places an image in the output folder for each size and returns the paths" do
      source_file = %SourceFile{
        metadata: %{image_opts: %{sizes: [100, 200]}},
        input_file: @input_file,
        output_file: @output_file
      }

      assert %SourceFile{
               source_file
               | metadata: %{
                   image_output_files: [
                     {100, @output_file_100},
                     {200, @output_file_200}
                   ],
                   image_opts: %{sizes: [100, 200]}
                 }
             } ==
               source_file
               |> Image.render()

      assert File.exists?(get_output_path(@output_file_100))
      assert File.exists?(get_output_path(@output_file_200))
    end

    test "does not run if the input file's mtime didn't change" do
      source_file = %SourceFile{
        metadata: %{image_opts: %{sizes: [100, 200]}},
        input_file: @input_file,
        output_file: @output_file
      }

      source_file
      |> Image.render()

      mtime =
        get_output_path(@output_file_100)
        |> get_modified_time!()

      source_file
      |> Image.render()

      new_mtime =
        get_output_path(@output_file_100)
        |> get_modified_time!()

      assert Timex.compare(mtime, new_mtime) == 0
    end

    test "runs if the input file's mtime changed" do
      source_file = %SourceFile{
        metadata: %{image_opts: %{sizes: [100, 200]}},
        input_file: @input_file,
        output_file: @output_file
      }

      source_file
      |> Image.render()

      mtime =
        get_output_path(@output_file_100)
        |> get_modified_time!()

      source_file.input_file
      |> get_input_path()
      |> File.touch!()

      source_file
      |> Image.render()

      new_mtime =
        get_output_path(@output_file_100)
        |> get_modified_time!()

      assert Timex.compare(mtime, new_mtime) == -1
    end

    test "doens't run if the options didn't change" do
      source_file = %SourceFile{
        metadata: %{image_opts: %{sizes: [100, 200]}},
        input_file: @input_file,
        output_file: @output_file
      }

      source_file
      |> Image.render()

      mtime =
        get_output_path(@output_file_100)
        |> get_modified_time!()

      source_file
      |> Image.render()

      new_mtime =
        get_output_path(@output_file_100)
        |> get_modified_time!()

      assert Timex.compare(mtime, new_mtime) == 0
    end

    test "runs if the options changed" do
      %{metadata: %{image_output_files: outputs1}} =
        %SourceFile{
          metadata: %{image_opts: %{sizes: [100, 200]}},
          input_file: @input_file,
          output_file: @output_file
        }
        |> Image.render()

      %{metadata: %{image_output_files: outputs2}} =
        %SourceFile{
          metadata: %{
            image_opts: %{
              sizes: [100, 200],
              transformations: []
            }
          },
          input_file: @input_file,
          output_file: @output_file
        }
        |> Image.render()

      assert outputs1 != outputs2
    end
  end
end
