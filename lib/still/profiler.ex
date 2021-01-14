defmodule Still.Profiler do
  @profiler_layout "priv/still/profiler.slime"

  use GenServer

  alias Still.Compiler.{
    CompilationStage,
    ErrorCache,
    PreprocessorError
  }

  alias Still.{Preprocessor, SourceFile}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def timestamp do
    :os.system_time(:millisecond)
  end

  def register(%SourceFile{} = file, delta) do
    GenServer.cast(__MODULE__, {:register, file, delta})
  end

  def recompile do
    GenServer.call(__MODULE__, :recompile)
  end

  def init(:ok) do
    CompilationStage.subscribe()

    {:ok, %{}}
  end

  def handle_cast({:register, file, delta}, state) do
    key = hash_file(file)

    new_state = Map.put(state, key, %{source_file: file, delta: delta})

    {:noreply, new_state}
  end

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
