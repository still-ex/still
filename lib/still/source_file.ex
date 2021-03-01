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
    dependency_chain: [],
    extension: nil,
    metadata: %{},
    profilable: true,
    run_type: :render
  ]

  @type t :: %__MODULE__{
          content: binary() | nil,
          dependency_chain: list(binary()),
          extension: binary() | nil,
          input_file: binary(),
          metadata: map(),
          output_file: binary() | nil,
          profilable: boolean(),
          run_type: :render | :compile
        }
end
