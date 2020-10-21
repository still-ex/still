defmodule Still.Compiler.PreprocessorError do
  defexception [
    :message,
    :content,
    :variables,
    :preprocessor,
    :remaining_preprocessors,
    :stacktrace
  ]

  require Logger

  import Still.Utils

  def handle_compile(%__MODULE__{} = e) do
    extension =
      find_extension(e.variables, [
        e.preprocessor | e.remaining_preprocessors
      ])

    content = handle_render(e) |> add_dev_layout(extension)

    variables =
      e.variables
      |> Map.put(
        :extension,
        extension
      )

    new_file_path =
      Still.Compiler.File.set_output_file(%{
        input_fil: e.variables.file_path,
        variables: variables
      })
      |> get_output_path()

    File.mkdir_p!(Path.dirname(new_file_path))
    File.write(new_file_path, content)
  end

  def handle_render(%__MODULE__{} = e) do
    extension =
      find_extension(e.variables, [
        e.preprocessor | e.remaining_preprocessors
      ])

    Logger.error("#{e.variables.file_path} #{e.message}")

    do_render(extension, e)
  end

  defp do_render(".html", %__MODULE__{} = e) do
    details =
      e.stacktrace
      |> Enum.reduce("", fn {mod, fun, arity, args}, acc ->
        acc <>
          "<div><strong>#{mod}</strong> #{fun} #{arity} <em>#{inspect(args, pretty: true)}</em></div>"
      end)

    """
    <div class='dev-error'>
      <h1>#{e.variables.file_path} #{e.message}</h1>
      <details>
        <summary>Stacktrace</summary>
        #{details}
      </details>
      <details>
        <summary>Context</summary>
        #{inspect(e, pretty: true)}
      </details>
    </div>
    """
  end

  defp do_render(".css", %__MODULE__{} = e) do
    """
    body::after {
      content: '#{e.variables.file_path} #{e.message}';
    }
    """
  end

  defp do_render(".js", %__MODULE__{} = e) do
    html = do_render(".html", e)

    """
    document.getElementsByTagName('body')[0].innerHTML = `#{html}`
    """
  end

  defp add_dev_layout(content, ".html") do
    content |> Still.Compiler.File.DevLayout.wrap()
  end

  defp add_dev_layout(content, _ext) do
    content
  end

  defp find_extension(%{permalink: permalink}, _preprocessors) do
    Path.extname(permalink)
  end

  defp find_extension(%{file_path: file}, preprocessors) do
    preprocessors
    |> Enum.reduce(Path.extname(file), fn p, acc ->
      p.extension() || acc
    end)
  end
end
