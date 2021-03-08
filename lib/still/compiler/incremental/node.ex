defmodule Still.Compiler.Incremental.Node do
  @moduledoc """
  An incremental node represents a file, or folder, that is processed
  individually.

  Each file has a list of subscriptions and subcribers. The subscriptions are
  the files included by the current file. The subscribers are the files that the
  current file includes. When the current file changes, it notifies the
  subscribers and updates the subscriptions.

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
  alias Still.{Compiler, SourceFile}
  alias Still.Compiler.{ErrorCache, PreprocessorError}

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
  def compile(pid) do
    GenServer.call(pid, :compile, compilation_timeout())
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
  Adds a file to the list of files this process is subscribed to.
  """
  def add_subscription(pid, file) do
    GenServer.cast(pid, {:add_subscription, file})
  end

  @doc """
  Removes a file from the list of files subscribing to this process.
  """
  def remove_subscriber(pid, file) do
    GenServer.cast(pid, {:remove_subscriber, file})
  end

  @doc """
  Returns the compilation timeout defined in the config.

  You can change this by setting

    config :still, :compilation_timeout, 1_000_000
  """
  def compilation_timeout do
    Still.Utils.config(:compilation_timeout, @default_compilation_timeout)
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
  def handle_call(:compile, _from, %{cached_source_file: source_file} = state)
      when not is_nil(source_file) do
    {:reply, source_file, state}
  end

  def handle_call(:compile, _from, state) do
    case Compile.run(state) do
      {:ok, source_file} ->
        ErrorCache.set({:ok, source_file})
        {:reply, source_file, %{state | cached_source_file: source_file}}

      other ->
        {:reply, other, state}
    end
  catch
    :exit, {e, _} ->
      error = %PreprocessorError{
        message: inspect(e),
        stacktrace: __STACKTRACE__,
        source_file: %Still.SourceFile{input_file: state.file, run_type: :compile}
      }

      ErrorCache.set({:error, error})
      {:reply, :ok, state}

    :error, %PreprocessorError{} = e ->
      ErrorCache.set({:error, e})
      {:reply, :ok, state}
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
  def handle_cast(:changed, state) do
    {:noreply, %{state | cached_source_file: nil}}
  end

  def handle_cast({:remove_subscriber, file}, state) do
    subscribers = Enum.reject(state.subscribers, &(&1 == file))

    {:noreply, %{state | subscribers: subscribers}}
  end

  def handle_cast({:add_subscription, file}, state) do
    subscriptions = [file | state.subscriptions] |> Enum.uniq()

    {:noreply, %{state | subscriptions: subscriptions}}
  end

  defp do_render(%{dependency_chain: dependency_chain} = data, state) do
    source_file =
      %SourceFile{
        input_file: state.file,
        dependency_chain: [state.file | dependency_chain],
        metadata: Map.drop(data, [:dependency_chain])
      }
      |> Compiler.File.render()

    ErrorCache.set({:ok, source_file})

    {:reply, source_file, state}
  catch
    :exit, {e, _} ->
      error = %PreprocessorError{
        message: inspect(e),
        stacktrace: __STACKTRACE__,
        source_file: %Still.SourceFile{input_file: state.file, run_type: :render}
      }

      ErrorCache.set({:error, error})

      {:reply, error, state}

    :error, %PreprocessorError{} = error ->
      Logger.error(inspect(error))
      ErrorCache.set({:error, error})

      {:reply, error, state}
  end
end
