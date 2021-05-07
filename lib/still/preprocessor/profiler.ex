defmodule Still.Preprocessor.Profiler do
  alias Still.Preprocessor
  alias Still.Profiler
  alias Still.SourceFile

  use Preprocessor

  @impl true
  def render(%{metadata: metadata} = file) do
    if should_profile?(file) do
      start_time = Profiler.timestamp()

      metadata = Map.put(metadata, :_profiler_start_time, start_time)

      %{file | metadata: metadata}
    else
      file
    end
  end

  @impl true
  def after_render(%{metadata: %{_profiler_start_time: start_time}} = file) do
    end_time = Profiler.timestamp()
    Profiler.register(file, end_time - start_time)

    file
  end

  def after_render(file), do: file

  defp should_profile?(%SourceFile{profilable: profilable}) do
    profilable and Application.get_env(:still, :profiler, false)
  end

  defp should_profile?(_), do: false
end
