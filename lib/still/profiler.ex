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
  Return a timestamp of the current system time in milliseconds.
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
    Process.send(__MODULE__, :recompile, [])
  end

  @impl true
  def init(:ok) do
    layout =
      Application.app_dir(:still, @profiler_layout)
      |> File.read!()

    {:ok, %{layout: layout, stats: %{}, timer: nil}}
  end

  @impl true
  def handle_cast({:register, file, delta}, state) do
    if state.timer do
      Process.cancel_timer(state.timer)
    end

    new_stats = add_file_render_info(state.stats, file, delta)

    {:noreply, %{state | stats: new_stats, timer: Process.send_after(self(), :recompile, 100)}}
  end

  @impl true
  def handle_info(:recompile, state) do
    compile(state)
    {:noreply, %{state | timer: nil}}
  end

  defp compile(state) do
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
  end

  defp run_preprocessor(source_file) do
    Preprocessor.run(source_file, @preprocessors)

    ErrorCache.set({:ok, source_file})
  catch
    _, %PreprocessorError{} = e ->
      ErrorCache.set({:error, e})

    kind, payload ->
      error = %PreprocessorError{
        payload: payload,
        kind: kind,
        stacktrace: __STACKTRACE__,
        source_file: source_file
      }

      ErrorCache.set({:error, error})
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
