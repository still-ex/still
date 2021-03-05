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

  use GenServer

  alias Still.Compiler.{
    CompilationStage,
    ErrorCache,
    PreprocessorError
  }

  alias Still.{Preprocessor, SourceFile, Utils}

  alias Still.Preprocessor.{EEx, Save, Slime}

  @profiler_layout "priv/still/profiler.slime"
  @preprocessors [EEx, Slime, Save]

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

    layout =
      Application.app_dir(:still, @profiler_layout)
      |> File.read!()

    {:ok, %{layout: layout, stats: %{}}}
  end

  @impl true
  def handle_cast({:register, file, delta}, state) do
    new_stats = add_file_render_info(state.stats, file, delta)

    {:noreply, %{state | stats: new_stats}}
  end

  @impl true
  def handle_info(:bus_empty, state) do
    stats =
      state.stats
      |> Map.values()
      |> Enum.sort_by(&{&1.source_file.input_file, &1.delta}, :asc)

    %SourceFile{
      input_file: @profiler_layout,
      output_file: "profiler/index.html",
      content: state.layout,
      run_type: :compile,
      metadata: %{stats: stats},
      profilable: false
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
    Preprocessor.run(source_file, @preprocessors)

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

  defp add_file_render_info(stats, file, delta) do
    key = hash_file(file)

    Map.update(
      stats,
      key,
      %{source_file: file, delta: delta, nr_renders: 1, hash: key},
      fn data ->
        %{
          data
          | delta: delta + data.delta,
            nr_renders: data.nr_renders + 1
        }
      end
    )
  end

  defp hash_file(%SourceFile{input_file: file, metadata: metadata}) do
    metadata_hash =
      metadata
      |> Utils.Map.deep_atomify_keys()
      |> :erlang.phash2()
      |> to_string()

    file <> "-" <> metadata_hash
  end
end
