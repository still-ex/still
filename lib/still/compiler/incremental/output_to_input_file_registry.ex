defmodule Still.Compiler.Incremental.OutputToInputFileRegistry do
  @moduledoc """
  Keeps track of which input file generates an output file.
  This is used to compile a file when it's requested by the browser.
  """

  import Still.Utils

  @spec register(binary(), binary()) :: any()
  def register(input_file, output_file) do
    Registry.register(
      __MODULE__,
      output_file |> Still.Utils.get_output_path(),
      input_file
    )
  end

  @spec recompile(binary()) :: any()
  def recompile(output_file) do
    Registry.dispatch(__MODULE__, output_file, fn entries ->
      for {_pid, input_file} <- entries,
          do: compile_file(input_file)
    end)
  end
end
