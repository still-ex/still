defmodule Extatic.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Extatic.Utils

      setup do
        Application.put_env(:extatic, :pass_through_copy, [])

        Extatic.Utils.rm_output_dir()

        :ok
      end
    end
  end
end
