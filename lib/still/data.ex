defmodule Still.Data do
  import Still.Utils

  use GenServer

  @supported_extensions [".yml", ".exs", ".ex", ".json"]

  @initial_state %{global: %{}}

  @default_folder "_data"

  @moduledoc """
  Loads data files and makes data available in templates.
  Any file in the _#{@default_folder}_ folder will be loaded
  using the file's name as a key. For instance, a file in
  _#{@default_folder}/site.json_ with the contents:

      {
        "title": "Still"
      }

  Will be available in the templates as `@site.title`.

  You can also use folders to organise files; the same file in
  `_#{@default_folder}/default/site.json_` would be available
  in the templates as `@default.site.title`.

  The data folder can be changed in the config:

      config :still, Still.Data,
        folder: "#{@default_folder}"

  **Notice**: The data folder name should start with an underscore, otherwise
  Still will consider the pages inside as web pages or assets to build.

  It supports JSON (.json), YAML (.yml) and Elixir (.exs, .ex).
  """

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
    String.starts_with?(input_file, data_folder())
  end

  @impl true
  def init(_) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_call(:reset, _, _state) do
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
      data_folder()
      |> get_input_path()
      |> Path.join(rel_path)

    cond do
      supported_file?(path) ->
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
    {:ok, result} =
      data_folder()
      |> Path.join(input_file)
      |> get_input_path()
      |> read_file()

    put_in(
      data,
      Enum.map(path_components(input_file), &Access.key(&1, %{})),
      result
    )
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
        File.read!(file)
        |> Jason.decode!(keys: :atoms)
    end
  end

  defp path_components(input_file) do
    Enum.reduce(@supported_extensions, input_file, fn ext, input_file ->
      String.replace_suffix(input_file, ext, "")
    end)
    |> Path.split()
    |> Enum.map(&String.to_atom/1)
  end

  defp data_folder do
    Map.get(config(__MODULE__, %{}), :folder, @default_folder)
  end

  defp supported_file?(path) do
    File.regular?(path) && Enum.member?(@supported_extensions, Path.extname(path))
  end
end
