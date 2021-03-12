defmodule Still.Compiler.PreprocessorError do
  defexception [
    :payload,
    :kind,
    :source_file,
    :preprocessor,
    :remaining_preprocessors,
    :stacktrace
  ]

  require Protocol

  Protocol.derive(Jason.Encoder, __MODULE__, only: [:payload, :kind, :source_file])

  def message(error) do
    Exception.message(error.payload)
  end
end
