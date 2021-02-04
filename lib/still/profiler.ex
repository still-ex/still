defmodule Still.Profiler do
  @moduledoc """
  Implements a profiler that keeps track of the time each file takes to render.

  A file can be rendered or compiled multiple times in the same stage (e.g when
  being included), so the compiler hashes each file and metadata to distinguish
  between those.

  After the compilation is finished, a profiler report is generated and can be
  accessed at `/profiler.html`.

  The profiler should only run in development and can be disabled by setting:

      config :still, profiler: false
  """

  @profiler_layout "priv/still/profiler.slime"

  use GenServer

  alias Still.Compiler.{
    CompilationStage,
    ErrorCache,
    PreprocessorError
  }

  alias Still.{Preprocessor, SourceFile}

  @impl true
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Return a timestamp of the current system time in millseconds.
  """
  def timestamp do
    :os.system_time(:millisecond)
  end

  @doc """
  Save a `Still.SourceFile` and the rendering/compilation delta.
  """
  def register(%SourceFile{} = file, delta) do
    GenServer.cast(__MODULE__, {:register, file, delta})
  end

  @doc """
  Recompiles the HTML page. Should only be used for internal maintenance.
  """
  def recompile do
    GenServer.call(__MODULE__, :recompile)
  end

  @impl true
  def init(:ok) do
    CompilationStage.subscribe()

    {:ok, %{}}
  end

  @impl true
  def handle_cast({:register, file, delta}, state) do
    key = hash_file(file)

    new_state = Map.put(state, key, %{source_file: file, delta: delta})

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:bus_empty, state) do
    content =
      Application.app_dir(:still, @profiler_layout)
      |> File.read!()

    stats =
      state
      |> Map.values()
      |> Stream.map(fn %{source_file: source_file} = s ->
        input_file = String.trim(source_file.input_file, "/")
        source_file = %{source_file | input_file: input_file}

        %{s | source_file: source_file}
      end)
      |> Enum.sort_by(&{&1.source_file.input_file, &1.delta}, :asc)

    %SourceFile{
      input_file: @profiler_layout,
      content: content,
      run_type: :compile,
      metadata: %{stats: stats}
    }
    |> run_preprocessor()

    {:noreply, state}
  end

  @impl true
  def handle_call(:recompile, _from, state) do
    {:noreply, new_state} = handle_info(:bus_empty, state)

    {:reply, :ok, new_state}
  end

  defp run_preprocessor(source_file) do
    try do
      Preprocessor.run(source_file)

      ErrorCache.set({:ok, source_file})
    catch
      :exit, {e, _} ->
        error = %PreprocessorError{
          message: inspect(e),
          stacktrace: __STACKTRACE__,
          source_file: source_file
        }

        ErrorCache.set({:error, error})

      :error, %PreprocessorError{} = e ->
        ErrorCache.set({:error, e})
    end
  end

  defp hash_file(%SourceFile{input_file: file, metadata: metadata}) do
    ref = :crypto.hash_init(:sha256) |> :crypto.hash_update(file)

    metadata
    |> Enum.reduce(ref, fn {k, v}, acc ->
      acc
      |> :crypto.hash_update(to_string(k))
      |> :crypto.hash_update(to_string(v))
    end)
    |> :crypto.hash_final()
    |> Base.encode16()
  end
end
