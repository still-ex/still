defmodule Still.Compiler.Incremental.OutputFileRegistry do
  def register(output_file) do
    Registry.register(
      __MODULE__,
      output_file |> Still.Utils.get_output_path(),
      []
    )
  end

  @spec recompile(any) :: :ok
  def recompile(file) do
    Registry.dispatch(__MODULE__, file, fn entries ->
      for {pid, _} <- entries, do: apply(Still.Compiler.Incremental.Node, :compile, [pid])
    end)
  end
end
