defmodule Still.Preprocessor.ResponsiveImageTest do
  use Still.Case, async: false

  alias Still.Preprocessor.ResponsiveImage
  alias Still.SourceFile

  describe "render/1" do
    test "places an image in the output folder for each size and returns the paths" do
      source_file = %SourceFile{
        metadata: %{responsive_image_opts: %{sizes: [100, 200]}},
        input_file: "img/bg.jpg",
        output_file: "img/bg.jpg"
      }

      assert %SourceFile{
               source_file
               | metadata: %{
                   responsive_image_output_files: [
                     {100, "img/bg-100w.jpg"},
                     {200, "img/bg-200w.jpg"}
                   ],
                   responsive_image_opts: %{sizes: [100, 200]}
                 }
             } ==
               source_file
               |> ResponsiveImage.render()

      assert File.exists?(get_output_path("img/bg-100w.jpg"))
      assert File.exists?(get_output_path("img/bg-200w.jpg"))
    end
  end
end
