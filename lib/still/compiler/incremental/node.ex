defmodule Still.Compiler.Incremental.Node do
  @moduledoc """
  An incremental node represents a file that is processed individually.

  A file can be compiled or rendered:

  * Compile - compiling a file means, most times, running it thorugh a
  preprocessor and writing to to the destination folder.

  * Render - rendering a file means that the current file is being included by
  another file. Template files may return HTML and images could return a path.

  Incremental nodes attempt to compile/render files synchronously. This process
  can take a long time, which is usually fine, but it can be changed by setting
  the `:compilation_timeout` key in your `config/config.exs`. Default is
  `:infinity`.
  """

  use GenServer

  alias Still.Compiler.PreprocessorError

  require Logger

  @default_compilation_timeout :infinity

  def start_link(file: file) do
    GenServer.start_link(__MODULE__, %{file: file}, name: file |> String.to_atom())
  end

  @doc """
  Compiles the file mapped by the `Node` with the given PID.

  This PID can be obtained from `Still.Compiler.Incremental.Registry`.

  For difference between compilation and renderisation see
  `Still.Compiler.File`.
  """
  def compile(pid, opts \\ []) do
    GenServer.call(pid, {:compile, opts}, compilation_timeout())
  end

  @doc """
  Renders the file mapped by the `Node` with the given PID.

  This PID can be obtained from `Still.Compiler.Incremental.Registry`.

  For difference between compilation and renderisation see
  `Still.Compiler.File`.
  """
  def render(pid, data) do
    GenServer.call(pid, {:render, data}, compilation_timeout())
  end

  @doc """
  Returns the compilation timeout defined in the config.

  You can change this by setting

    config :still, :compilation_timeout, 1_000_000
  """
  def compilation_timeout do
    Still.Utils.config(:compilation_timeout, @default_compilation_timeout)
  end

  def compile_metadata(pid, opts \\ []) do
    GenServer.call(pid, {:compile_metadata, opts}, compilation_timeout())
  end

  def changed(pid) do
    GenServer.cast(pid, :changed)
  end

  @impl true
  def init(%{file: file}) do
    state = %{
      file: file,
      subscribers: [],
      subscriptions: [],
      cached_source_file: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_call({_, use_cache: true}, _from, %{cached_source_file: source_file} = state)
      when not is_nil(source_file) do
    {:reply, source_file, state}
  end

  def handle_call({:compile, _}, from, state) do
    froms = all_waiting_compile([from])

    try do
      source_file = __MODULE__.Compile.run(state.file)

      Enum.each(froms, &GenServer.reply(&1, source_file))

      {:noreply, %{state | cached_source_file: source_file}}
    catch
      _, %PreprocessorError{} ->
        Enum.each(froms, &GenServer.reply(&1, :ok))

        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:render, data}, _from, state) do
    source_file = __MODULE__.Render.run(state.file, data)

    {:reply, source_file, state}
  catch
    _, %PreprocessorError{} = error ->
      {:reply, error, state}
  end

  @impl true
  def handle_call({:compile_metadata, _opts}, _from, state) do
    source_file = __MODULE__.Compile.run(state.file, :compile_metadata)

    {:reply, source_file, %{state | cached_source_file: source_file}}
  catch
    _, %PreprocessorError{} ->
      {:reply, :ok, state}
  end

  @impl true
  def handle_cast(:changed, state) do
    {:noreply, %{state | cached_source_file: nil}}
  end

  defp all_waiting_compile(acc) do
    receive do
      {:"$gen_call", from, {:compile, _}} -> all_waiting_compile([from | acc])
    after
      0 -> acc
    end
  end
end
