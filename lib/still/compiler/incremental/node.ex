defmodule Still.Compiler.Incremental.Node do
  @doc """
  A Incremental Node represents a file, or folder, that is processed
  individually. Each file has a list of subscriptions and subcribers. The
  subscriptions are the files included by the current file. The subscribers are
  the files that the current file includes. When the current file changes, it
  notifies the subscribers, and updates the subscriptions.

  A file can be compiled or rendered:

  * Compile - compiling a file means, most
  times, running it thorugh a preprocessor and writing to to the destination
  folder.

  * Render - rendering a file means that the current file is being
  included by another file. Template files may return HTML and images could return a path.

  Incremental nodes attempt to compile/render files synchronously. If a file
  takes longer than 5 seconds to be compiled, this process will crash. Although
  not a common occurence, this can be configured by setting the
  `:compilation_timeout` key in your `config/config.exs`. Default is `5_000`
  (in milliseconds).
  """

  use GenServer

  alias Still.Compiler
  alias Still.Compiler.PreprocessorError
  alias Still.Compiler.ErrorCache
  alias __MODULE__.Compile

  @default_compilation_timeout 15_000

  def start_link(file: file) do
    GenServer.start_link(__MODULE__, %{file: file}, name: file |> String.to_atom())
  end

  def compile(pid) do
    GenServer.call(pid, :compile, compilation_timeout())
  end

  def render(pid, data, subscriber \\ nil) do
    GenServer.call(pid, {:render, data, subscriber}, compilation_timeout())
  end

  def add_subscription(pid, file) do
    GenServer.cast(pid, {:add_subscription, file})
  end

  def remove_subscriber(pid, file) do
    GenServer.cast(pid, {:remove_subscriber, file})
  end

  @impl true
  def init(%{file: file}) do
    state = %{
      file: file,
      subscribers: [],
      subscriptions: []
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:compile, _from, state) do
    with {:ok, source_file} <- Compile.run(state) do
      ErrorCache.set({:ok, source_file})
      {:reply, source_file, state}
    else
      other ->
        {:reply, other, state}
    end
  catch
    :error, %PreprocessorError{} = e ->
      ErrorCache.set({:error, e})

      {:reply, :ok, state}
  end

  @impl true
  def handle_call({:render, data, nil}, _from, state) do
    {:reply, do_render(data, state), state}
  catch
    :error, %PreprocessorError{} = e ->
      ErrorCache.set({:error, e})
      {:reply, %Still.SourceFile{content: "", input_file: state.file}, state}
  end

  @impl true
  def handle_call({:render, data, subscriber}, _from, state) do
    subscribers = [subscriber | state.subscribers] |> Enum.uniq() |> Enum.reject(&is_nil/1)
    source_file = do_render(data, state)
    ErrorCache.set({:ok, source_file})

    {:reply, source_file, %{state | subscribers: subscribers}}
  catch
    :error, %PreprocessorError{} = e ->
      ErrorCache.set({:error, e})
      {:reply, %Still.SourceFile{content: "", input_file: state.file}, state}
  end

  @impl true
  def handle_cast({:remove_subscriber, file}, state) do
    subscribers = Enum.reject(state.subscribers, &(&1 == file))

    {:noreply, %{state | subscribers: subscribers}}
  end

  @impl true
  def handle_cast({:add_subscription, file}, state) do
    subscriptions = [file | state.subscriptions] |> Enum.uniq()

    {:noreply, %{state | subscriptions: subscriptions}}
  end

  defp do_render(data, state) do
    Compiler.File.render(state.file, data)
  end

  defp compilation_timeout do
    Still.Utils.config(:compilation_timeout, @default_compilation_timeout)
  end
end
