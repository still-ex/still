defmodule Still.Compiler.ErrorCache do
  @moduledoc """
  Saves an error occurring within a file's compilation and allows them to be
  retrieved for a prettified display.

  Since files are compiled asynchronously, the browser (or other interested
  parties) require a centralised access to compilation errors.
  """
  use GenServer

  alias Still.SourceFile

  import Still.Utils

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Save the given error or clear it if the compilation was successful.

  If `result` is `{:ok, source_file}`, the error cache for the given file is
  cleared. Otherwise it is updated.
  """
  def set(result) do
    GenServer.cast(__MODULE__, {:set, result})
  end

  @doc """
  Clears the saved errors for the given input file.
  """
  def clear(input_file) do
    GenServer.cast(__MODULE__, {:clear, input_file})
  end

  @doc """
  Clears the errors for all files. This function is dangerous and should be
  only used for debugging and testing purposes.
  """
  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  @doc """
  Retrieve all saved errors, for all files.
  """
  def get_errors do
    GenServer.call(__MODULE__, :get_errors)
  end

  @impl true
  def init(_) do
    {:ok, %{errors: %{}}}
  end

  @impl true
  def handle_call(:get_errors, _, state) do
    {:reply, state.errors, state}
  end

  def handle_cast({:set, {:ok, source_file}}, state) do
    {errors, previous_errors} =
      state.errors
      |> Enum.split_with(fn {_, error} ->
        error.source_file.input_file != source_file.input_file
      end)

    recompile_source_files(previous_errors)

    state = %{state | errors: Enum.into(errors, %{})}

    {:noreply, state}
  end

  def handle_cast({:set, {:error, error}}, state) do
    errors =
      state.errors
      |> Map.put(source_file_id(error.source_file), error)

    state = %{state | errors: errors}

    {:noreply, state}
  end

  @impl true
  def handle_cast({:clear, input_file}, state) do
    {:noreply, state |> Map.delete(input_file)}
  end

  @impl true
  def handle_cast(:clear, _state) do
    {:noreply, %{errors: %{}}}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp source_file_id(%SourceFile{dependency_chain: dependency_chain}) do
    dependency_chain
    |> Enum.join(" <- ")
  end

  defp recompile_source_files([]), do: nil

  defp recompile_source_files(errors) do
    errors
    |> Enum.map(fn {_, error} ->
      Task.async(fn ->
        error.source_file.dependency_chain
        |> List.last()
        |> compile_file_metadata()
      end)
    end)
    |> Task.await_many(:infinity)
  end
end
