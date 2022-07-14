defmodule Still.DataTest do
  use Still.Case, async: false

  alias Still.Data

  setup do
    Data.reset()

    :ok
  end

  describe "load/1" do
    test "reads from the _data folder" do
      assert Data.load() == :ok

      assert Data.global() ==
               %{
                 people: %{"authors" => ["gabriel", "fernando"]},
                 site: %{
                   colors: %{
                     "black" => "#222",
                     "brown" => "#A46F41",
                     "orange" => "#DA9F5D",
                     "red" => "#D57050",
                     "white" => "#F3EAC3"
                   },
                   footer: %{
                     copy: %{message: "This is the end of the website."}
                   }
                 }
               }
    end

    test "uses the user defined folder" do
      Application.put_env(:still, Still.Data, %{folder: "_data2"})

      assert Data.load() == :ok

      assert Data.global() ==
               %{
                 test: %{title: "Still"}
               }

      Application.delete_env(:still, Still.Data)
    end
  end

  describe "global/1" do
    test "reads from memory" do
      assert Data.global() == %{}

      Data.load()

      assert Data.global() ==
               %{
                 people: %{"authors" => ["gabriel", "fernando"]},
                 site: %{
                   colors: %{
                     "black" => "#222",
                     "brown" => "#A46F41",
                     "orange" => "#DA9F5D",
                     "red" => "#D57050",
                     "white" => "#F3EAC3"
                   },
                   footer: %{
                     copy: %{message: "This is the end of the website."}
                   }
                 }
               }
    end
  end
end
