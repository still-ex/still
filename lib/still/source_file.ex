defmodule Still.SourceFile do
  @moduledoc """
  The SourceFile retains all information regarding a file being compiled in
  the system. It's conceptually similar to the `conn` variable in a Phoenix
  app. The idea is that different subsystems transform this struct and pass it
  to the next.
  """

  @enforce_keys [:input_file]

  @derive Jason.Encoder
  defstruct [
    :input_file,
    :output_file,
    content: nil,
    metadata: %{},
    extension: nil,
    run_type: :render
  ]

  @type t :: %__MODULE__{
          run_type: :render | :compile,
          content: binary() | nil,
          extension: binary() | nil,
          input_file: binary(),
          output_file: binary() | nil,
          metadata: map()
        }
end
