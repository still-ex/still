defmodule Still.SourceFile do
  @moduledoc """
  The SourceFile retains all information regarding a file being compiled in
  the system. It's conceptually similar to the `conn` variable in a Phoenix
  app. The idea is that different subsystems transform this struct and pass it
  to the next.
  """

  @enforce_keys [:input_file]

  @derive Jason.Encoder
  defstruct [:input_file, :output_file, content: nil, variables: %{}, extension: nil]

  @type t :: %__MODULE__{
          content: String.t(),
          input_file: String.t(),
          output_file: String.t()
        }
end
