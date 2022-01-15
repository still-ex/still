defmodule Still.Data do
  import Still.Utils

  use GenServer

  @supported_extensions [".yml", ".exs", ".ex", ".json"]

  @initial_state %{global: %{}}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def load do
    GenServer.call(__MODULE__, :load, :infinity)
  end

  def global do
    GenServer.call(__MODULE__, :global, :infinity)
  end

  def reset do
    GenServer.call(__MODULE__, :reset, :infinity)
  end

  def member?(input_file) do
    String.starts_with?(input_file, "_data")
  end

  @impl true
  def init(_) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_call(:reset, _, state) do
    {:reply, :ok, @initial_state}
  end

  @impl true
  def handle_call(:global, _, state) do
    {:reply, state.global, state}
  end

  @impl true
  def handle_call(:load, _, state) do
    data =
      data_files()
      |> sort_files()
      |> Enum.reduce(%{}, &load_file/2)

    {:reply, :ok, %{state | global: data}}
  end

  defp data_files(rel_path \\ "") do
    path =
      "_data"
      |> get_input_path()
      |> Path.join(rel_path)

    cond do
      File.regular?(path) && Enum.member?(@supported_extensions, Path.extname(path)) ->
        [rel_path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&data_files(Path.join(rel_path, &1)))

      true ->
        []
    end
    |> List.flatten()
  end

  defp sort_files(files) do
    files
    |> Enum.sort_by(fn file ->
      file
      |> path_components()
      |> length()
    end)
  end

  defp load_file(input_file, data) do
    "_data"
    |> Path.join(input_file)
    |> get_input_path()
    |> read_file()
    |> case do
      {:ok, result} ->
        put_in(
          data,
          Enum.map(path_components(input_file), &Access.key(&1, %{})),
          result
        )

      {:error, err} ->
        raise err
    end
  end

  defp read_file(file) do
    case Path.extname(file) do
      ".yml" ->
        YamlElixir.read_from_file(file, atoms: true)

      ".exs" ->
        {result, _} = Code.eval_file(file)
        {:ok, result}

      ".ex" ->
        {result, _} = Code.eval_file(file)
        {:ok, result}

      ".json" ->
        {:ok, content} = File.read(file)

        Jason.decode(content, keys: :atoms)
    end
  end

  defp path_components(input_file) do
    Enum.reduce(@supported_extensions, input_file, fn ext, input_file ->
      String.replace_suffix(input_file, ext, "")
    end)
    |> Path.split()
    |> Enum.map(&String.to_atom/1)
  end
end
