defmodule Still.Compiler.Incremental.OutputToInputFileRegistry do
  @moduledoc """
  Keeps track of which input file generates each output file.
  It's used to identify which file needs to be compiled when there's a request from the browser.
  """

  import Still.Utils

  alias Still.SourceFile

  require Logger

  @doc """
  Registers an input and output pair.
  """
  @spec register(binary(), binary()) :: any()
  def register(input_file, output_file) do
    Registry.register(
      __MODULE__,
      get_output_path(output_file),
      input_file
    )
  end

  @doc """
  Compiles the input files for the given output file.
  """
  @spec recompile(binary()) :: any()
  def recompile(output_path) do
    output_file = get_relative_output_path(output_path)

    Registry.lookup(__MODULE__, output_path)
    |> Enum.flat_map(fn {_pid, input_file} ->
      compile_file(input_file, run_type: :compile_dev, requested_output_file: output_file)
    end)
    |> Enum.filter(fn v -> v != :ok end)
    |> Enum.filter(fn %{output_file: other_output_file} -> output_file == other_output_file end)
    |> case do
      [source_file] ->
        source_file

      [_source_file | _other] ->
        Logger.error("There is more than one file registered under the same name")
        Logger.flush()
        System.halt(1)

      _ ->
        %SourceFile{input_file: ""}
    end
  end

  @doc """
  Returns a list of the registered input files for the given output.
  """
  @spec lookup(binary()) :: list({pid(), binary()})
  def lookup(output_file) do
    Registry.lookup(__MODULE__, output_file)
  end
end
