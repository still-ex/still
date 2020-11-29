defmodule Still.Compiler.PreprocessorError do
  defexception [
    :message,
    :source_file,
    :preprocessor,
    :remaining_preprocessors,
    :stacktrace
  ]

  require Protocol

  Protocol.derive(Jason.Encoder, __MODULE__, only: [:message, :source_file])
end
