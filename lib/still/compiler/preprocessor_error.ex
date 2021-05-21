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

  @spec message(%{
          :payload => atom | %{:__exception__ => true, :__struct__ => atom, optional(any) => any},
          optional(any) => any
        }) :: binary
  def message(%{payload: payload}) when is_atom(payload) do
    payload |> to_string()
  end

  def message(%{payload: payload}) do
    Exception.message(payload)
  end
end
