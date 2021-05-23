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

  alias __MODULE__.Compile
  alias Still.{Preprocessor, SourceFile}
  alias Still.Compiler.{ErrorCache, Incremental.OutputToInputFileRegistry, PreprocessorError}

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
  def render(pid, data, subscriber \\ nil) do
    GenServer.call(pid, {:render, data, subscriber}, compilation_timeout())
  end

  @doc """
  Returns the compilation timeout defined in the config.

  You can change this by setting

    config :still, :compilation_timeout, 1_000_000
  """
  def compilation_timeout do
    Still.Utils.config(:compilation_timeout, @default_compilation_timeout)
  end

  def metadata(pid, data \\ %{}) do
    GenServer.call(pid, {:metadata, data}, compilation_timeout())
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
      result = do_compile(state)
      Enum.each(froms, &GenServer.reply(&1, result))

      case result do
        %SourceFile{} = source_file ->
          {:noreply, %{state | cached_source_file: source_file}}

        _ ->
          {:noreply, state}
      end
    catch
      _, %PreprocessorError{} = error ->
        handle_compile_error(error)

        Enum.each(froms, &GenServer.reply(&1, :ok))

        {:noreply, state}

      kind, payload ->
        error = %PreprocessorError{
          payload: payload,
          kind: kind,
          stacktrace: __STACKTRACE__,
          source_file: %Still.SourceFile{input_file: state.file, run_type: :compile}
        }

        handle_compile_error(error)

        Enum.each(froms, &GenServer.reply(&1, :ok))

        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:render, data, nil}, _from, state) do
    do_render(data, state)
  end

  @impl true
  def handle_call({:render, data, subscriber}, _from, state) do
    subscribers =
      [subscriber | state.subscribers]
      |> Enum.uniq()
      |> Enum.reject(&is_nil/1)

    do_render(data, %{state | subscribers: subscribers})
  end

  @impl true
  def handle_call({:metadata, data}, _from, state) do
    # do_metadata(data, state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast(:changed, state) do
    {:noreply, %{state | cached_source_file: nil}}
  end

  defp do_compile(%{file: input_file}) do
    source_file = %SourceFile{
      input_file: input_file,
      dependency_chain: [input_file],
      run_type: :compile
    }

    case __MODULE__.Compile.run(source_file) do
      %{output_file: output_file, input_file: input_file} = source_file ->
        ErrorCache.set({:ok, source_file})
        OutputToInputFileRegistry.register(input_file, output_file)
        source_file

      other ->
        Logger.error("Failed to compile #{source_file.input_file}")
        other
    end
  end

  defp do_render(%{dependency_chain: dependency_chain} = data, state) do
    %SourceFile{
      input_file: state.file,
      dependency_chain: [state.file | dependency_chain],
      run_type: :render,
      metadata: Map.drop(data, [:dependency_chain])
    }
    |> Preprocessor.run()
    |> case do
      %SourceFile{} = source_file ->
        Logger.debug("Rendered #{state.file}")
        ErrorCache.set({:ok, source_file})
        {:reply, source_file, state}

      error ->
        Logger.error("Failed to render #{state.file}")
        ErrorCache.set(error)
        {:reply, error, state}
    end
  catch
    _, %PreprocessorError{} = error ->
      {:reply, error, state}

    kind, payload ->
      error = %PreprocessorError{
        payload: payload,
        kind: kind,
        stacktrace: __STACKTRACE__,
        source_file: %Still.SourceFile{
          input_file: state.file,
          run_type: :render,
          dependency_chain: [state.file | dependency_chain]
        }
      }

      {:reply, error, state}
  end

  defp handle_compile_error(error) do
    Logger.error(error)

    if Still.Utils.compilation_task?() do
      System.stop(1)
    else
      ErrorCache.set({:error, error})
    end
  end

  defp all_waiting_compile(acc) do
    receive do
      {:"$gen_call", from, {:compile, _}} -> all_waiting_compile([from | acc])
    after
      0 -> acc
    end
  end
end
