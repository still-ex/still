defmodule Still.Image.Preprocessor.OutputFile do
  @enforce_keys [:width, :file]

  defstruct [
    :width,
    :file
  ]

  @type t :: %__MODULE__{
          width: integer(),
          file: binary()
        }
end
