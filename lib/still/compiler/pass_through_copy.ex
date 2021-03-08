defmodule Still.Compiler.PassThroughCopy do
  @moduledoc """
  Copies a file from the input path to the output directory without changing it.

  ## Matching parameters

  You can configure matching parameters by setting

      config :still,
        pass_through_copy: ["img/logo.png"]

  In the example above, the file `logo.png` inside the `img` folder will be copied
  to the `img` folder in the output. But if you write something like this:

      config :still,
        pass_through_copy: ["img"]

  **Any file or folder that starts with the string `img` will be copied, which may
  include an `img` folder or a file named `img.png`.** So you need to be mindful
  of that.

  You can also use regular expressions:

      config still,
        pass_through_copy: [~r/.*\.jpe?g/]

  **Sometimes you want to alter the file name or path but keep the content of the
  files.** The configuration allows this by using tuples. The key will be used
  to match the input folder, and the value will be used to transform the input
  path:

      config :still,
        pass_through_copy: [css: "styles"]

      # this is also valid:
      # config :still,
      #   pass_through_copy: [{"css", "styles"}]

  In the example above, the `css` folder from the input folder but will be
  renamed to `styles` in the output folder.
  """

  import Still.Utils

  require Logger

  @doc """
  Attempts to copy a file from the input path to the output directory without changing.

  If the file doesn't match any configured name, `:no_match` is returned.

  See the [Matching Parameters](#module-matching-parameters) section.
  """
  def try(file) do
    case get_pass_through_copy_match(file) do
      {input_file, output_file} ->
        run(file, replace_match(file, input_file, output_file))

      output_file when not is_nil(output_file) ->
        run(file)

      _ ->
        :no_match
    end
  end

  defp run(file), do: run(file, file)

  defp run(file, output_file) do
    case do_run(file, output_file) do
      :ok ->
        Logger.info("Pass through copy #{file}")
        :ok

      _ ->
        Logger.error("Failed to process #{file} in #{__MODULE__}")
        :error
    end
  end

  defp do_run(file, output_file) do
    get_output_path(output_file)
    |> Path.dirname()
    |> File.mkdir_p!()

    File.cp(get_input_path(file), get_output_path(output_file))
  end

  defp get_pass_through_copy_match(file) do
    config(:pass_through_copy, [])
    |> Enum.find(&match_pass_through_copy(file, &1))
  end

  defp match_pass_through_copy(file, {match, _output}) when is_binary(match),
    do: match_pass_through_copy(file, match)

  defp match_pass_through_copy(file, {match, _output}) when is_atom(match),
    do: match_pass_through_copy(file, match |> Atom.to_string())

  defp match_pass_through_copy(file, match) when is_binary(match),
    do: String.starts_with?(file, match)

  defp match_pass_through_copy(file, match) do
    cond do
      Regex.regex?(match) -> String.match?(file, match)
      true -> false
    end
  end

  defp replace_match(file, input_match, output_match) when is_atom(output_match),
    do: replace_match(file, input_match, output_match |> Atom.to_string())

  defp replace_match(file, input_match, output_match) when is_atom(input_match),
    do: replace_match(file, input_match |> Atom.to_string(), output_match)

  defp replace_match(file, input_match, output_match) do
    String.replace_prefix(file, input_match, output_match)
  end
end
