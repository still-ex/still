defmodule Extatic.FileProcess do
  @doc """
  A FileProcess represents a file, or folder, that is processed
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
  """

  use GenServer

  alias Extatic.Compiler
  alias __MODULE__.Compile

  def start_link(file: file) do
    GenServer.start_link(__MODULE__, %{file: file}, name: file |> String.to_atom())
  end

  def compile(pid) do
    GenServer.call(pid, :compile)
  end

  def render(pid, data, parent_file) do
    GenServer.call(pid, {:render, data, parent_file})
  end

  def add_subscription(pid, file) do
    GenServer.cast(pid, {:add_subscription, file})
  end

  def remove_subscriber(pid, file) do
    GenServer.cast(pid, {:remove_subscriber, file})
  end

  def add_variable(pid, context, name, value) do
    GenServer.cast(pid, {:add_variable, context, name, value})
  end

  def get_variable(pid, context, name) do
    GenServer.call(pid, {:get_variable, context, name})
  end

  @impl true
  def init(%{file: file}) do
    state = %{
      file: file,
      subscribers: [],
      subscriptions: [],
      contexts: %{"main" => %{}}
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:compile, _from, state) do
    with result <- Compile.run(state) do
      {:reply, result, state}
    end
  end

  @impl true
  def handle_call({:render, data, parent_file}, _from, state) do
    subscribers = [parent_file | state.subscribers] |> Enum.uniq()
    data = Map.put(data, :current_context, parent_file)

    {:reply, do_render(data, state), %{state | subscribers: subscribers}}
  end

  @impl true
  def handle_call({:get_variable, ctx_name, name}, _from, state) do
    context = state.contexts[ctx_name] || state.contexts["main"]
    value = context[name]

    {:reply, value, state}
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

  @impl true
  def handle_cast({:add_variable, ctx_name, name, value}, state) do
    context = state.contexts[ctx_name] || %{}
    context = Map.put(context, name, value)
    contexts = Map.put(state.contexts, ctx_name, context)

    {:noreply, %{state | contexts: contexts}}
  end

  defp do_render(data, state) do
    Compiler.File.render(state.file, data)
  end
end
