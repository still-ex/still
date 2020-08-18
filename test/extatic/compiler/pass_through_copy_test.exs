defmodule Extatic.Compiler.PassThroughCopyTest do
  use Extatic.Case

  alias Extatic.Compiler.PassThroughCopy

  describe "try" do
    test "matches folders" do
      Application.put_env(:extatic, :pass_through_copy, css: "styles", img: "img")

      PassThroughCopy.try("css")
      PassThroughCopy.try("img")

      assert File.exists?(get_output_path("styles"))
      assert File.exists?(get_output_path("img"))
    end

    test "copies files inside matching folders" do
      Application.put_env(:extatic, :pass_through_copy, css: "styles")

      PassThroughCopy.try("css/theme.css")

      assert File.exists?(get_output_path("styles/theme.css"))
    end

    test "matches files" do
      Application.put_env(:extatic, :pass_through_copy, ["logo.jpg", css: "styles"])

      PassThroughCopy.try("logo.jpg")

      assert File.exists?(get_output_path("logo.jpg"))
    end

    test "matches regular expressions" do
      Application.put_env(:extatic, :pass_through_copy, [~r/.*jpg/])

      PassThroughCopy.try("logo.jpg")
      PassThroughCopy.try("img/bg.jpg")

      assert File.exists?(get_output_path("logo.jpg"))
      assert File.exists?(get_output_path("img/bg.jpg"))
    end
  end
end
