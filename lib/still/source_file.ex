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
    requested_output_file: nil,
    run_type: :render
  ]

  @type t :: %__MODULE__{
          content: binary() | nil,
          dependency_chain: list(binary()),
          extension: binary() | nil,
          input_file: binary(),
          metadata: map(),
          output_file: binary() | nil,
          requested_output_file: binary() | nil,
          profilable: boolean(),
          run_type: :render | :compile | :compile_metadata | :compile_dev
        }

  def first(%__MODULE__{} = source_file) when not is_list(source_file), do: first([source_file])
  def first(source_files), do: hd(source_files)

  def for_extension(%__MODULE__{} = source_file, _extension),
    do: source_file

  def for_extension([source_file], _extension),
    do: source_file

  def for_extension([source_file | source_files], extension) do
    if source_file.extension == extension do
      source_file
    else
      for_extension(source_files, extension)
    end
  end
end
