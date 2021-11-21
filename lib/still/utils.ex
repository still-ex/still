defmodule Still.Utils do
  @moduledoc """
  Collection of utility functions.
  """

  alias Still.SourceFile
  alias Still.Compiler.Incremental.{Node, Registry}

  def module_exists?(module) do
    :module == elem(Code.ensure_compiled(module), 0)
  end

  @doc """
  Checks whether a file should be ignored by Still or not.
  """
  @spec ignored_file?(binary()) :: boolean()
  def ignored_file?(file) do
    config(:ignore_files, [])
    |> Enum.any?(&ignored_file_match(file, &1))
  end

  defp ignored_file_match(file, match) when is_binary(match),
    do: String.starts_with?(file, match)

  defp ignored_file_match(file, match) do
    cond do
      Regex.regex?(match) -> String.match?(file, match)
      true -> false
    end
  end

  @doc """
  Compiles a file.
  """
  @spec compile_file(binary(), any()) :: SourceFile.t()
  def compile_file(file, opts \\ []) do
    Registry.get_or_create_file_process(file)
    |> Node.compile(opts)
  end

  @doc """
  Compiles a file's metadata.
  """
  @spec compile_file_metadata(binary(), any()) :: SourceFile.t()
  def compile_file_metadata(file, opts \\ []) do
    Registry.get_or_create_file_process(file)
    |> Node.compile_metadata(opts)
  end

  @doc """
  Returns true if the given file exists in the input path. Returns false otherwise.
  """
  def input_file_exists?(file) do
    file
    |> get_input_path()
    |> File.exists?()
  end

  @doc """
  Returns true if the modified time of the imput file is different than the output file.
  """
  def input_file_changed?(input_file, output_file) do
    with {:ok, input_mtime} <-
           input_file
           |> get_input_path()
           |> get_modified_time(),
         {:ok, output_mtime} <-
           output_file
           |> get_output_path()
           |> get_modified_time() do
      Timex.compare(input_mtime, output_mtime) != -1
    else
      _ ->
        true
    end
  end

  @doc """
  Returns the modified time of a given file. Errors if the file does not exist.
  """
  def get_modified_time!(path) do
    path
    |> File.stat!()
    |> Map.get(:mtime)
    |> Timex.to_datetime()
  end

  @doc """
  Returns the modified time of a given file as a `DateTime` struct or the
  `:error` atom if the file doesn't exist.
  """
  def get_modified_time(path) do
    path
    |> File.stat()
    |> case do
      {:ok, stat} ->
        {:ok,
         stat
         |> Map.get(:mtime)
         |> Timex.to_datetime()}

      _ ->
        :error
    end
  end

  @doc """
  Delegates the call to the current `Still.Preprocessor.Image.Adapter`.
  """
  def get_image_info(file) do
    Still.Preprocessor.Image.adapter().get_image_info(file)
  end

  @doc """
  Returns the current input path for a given file, prepending it with the
  site's `input` directory. See `get_input_path/0`.
  """
  def get_input_path(%SourceFile{input_file: file}),
    do: Path.join(get_input_path(), file)

  def get_input_path(file), do: Path.join(get_input_path(), file)

  @doc """
  Returns the absolute path configured as the site's entrypoint.

  This is the value set by

      config :still, input: "path/to/site"
  """
  def get_input_path do
    config!(:input)
    |> Path.expand()
  end

  @doc """
  Returns the current output path for a given file, prepending it with the
  site's `output` directory. See `get_output_path/0`.
  """
  def get_output_path(%SourceFile{output_file: file}), do: Path.join(get_output_path(), file)

  def get_output_path(file), do: Path.join(get_output_path(), file)

  @doc """
  Returns the absolute path configured as the site's output destination.

  This is the value set by

      config :still, output: "path/to/site"
  """
  def get_output_path do
    config!(:output)
    |> Path.expand()
  end

  @doc """
  Receives an absolute path and converts it to relative by trimming the site's
  entrypoint directory.
  """
  def get_relative_input_path(full_path) do
    full_path
    |> String.replace(config!(:input), "")
    |> String.trim_leading("/")
  end

  @doc """
  Returns the site's base URL.
  """
  def get_base_url do
    config(:base_url, "")
  end

  @doc """
  Recursively cleans the site's output directory.
  """
  def rm_output_dir do
    get_output_path()
    |> File.rm_rf()
  end

  @doc """
  Creates the output directory.
  """
  def mk_output_dir do
    get_output_path()
    |> File.mkdir_p!()
  end

  @doc """
  Creates the directory by the given path, relative to the output directory.
  """
  def mk_output_dir(path) do
    get_output_path(path)
    |> File.mkdir_p!()
  end

  @doc """
  Recursively removes all files from the site's output directory.
  """
  def clean_output_dir do
    File.rm_rf(get_output_path())
    File.mkdir!(get_output_path())
  end

  @doc """
  Recursively removes all files from the given path, relative to the output
  directory.
  """
  def clean_output_dir(path) do
    File.rm_rf(get_output_path(path))
    File.mkdir!(get_output_path(path))
  end

  @doc """
  Returns true when the current execution was started by #{Mix.Tasks.Still.Compile}
  """
  def compilation_task? do
    config(Mix.Tasks.Still.Compile.config_key(), false)
  end

  @doc """
  Returns the value configured for `:still` by the given key. Errors if it
  doesn't exist.
  """
  def config!(key), do: Application.fetch_env!(:still, key)

  @doc """
  Returns the value configured for `:still` by the given key. Returns the
  provided default if it doesn't exist.
  """
  def config(key, default), do: Application.get_env(:still, key, default)
end
