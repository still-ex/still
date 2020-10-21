defmodule Still.Compiler.PreprocessorError do
  defexception [
    :message,
    :source_file,
    :preprocessor,
    :remaining_preprocessors,
    :stacktrace
  ]

  require Logger

  alias Still.SourceFile

  import Still.Utils

  def handle_compile(%__MODULE__{} = e) do
    extension =
      find_extension(e.source_file, [
        e.preprocessor | e.remaining_preprocessors
      ])

    source_file = %{e.source_file | extension: extension}

    content = handle_render(%{e | source_file: source_file}) |> add_dev_layout(extension)

    new_file_path =
      Still.Compiler.File.set_output_file(source_file)
      |> get_output_path()

    File.mkdir_p!(Path.dirname(new_file_path))
    File.write(new_file_path, content)
  end

  def handle_render(%__MODULE__{} = e) do
    extension =
      find_extension(e.source_file, [
        e.preprocessor | e.remaining_preprocessors
      ])

    Logger.error("#{e.source_file.input_file} #{e.message}")

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
      <h1>#{e.source_file.input_file} #{e.message}</h1>
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
      content: '#{e.source_file.input_file} #{e.message}';
    }
    """
  end

  defp do_render(".js", %__MODULE__{} = e) do
    html = do_render(".html", e)

    """
    window.addEventListener('load', () => {
      let node = document.createElement("div");
      document.body.appendChild(node);
      node.innerHTML = `#{html}`
    });
    """
  end

  defp add_dev_layout(content, ".html") do
    content |> Still.Compiler.File.DevLayout.wrap() |> Map.get(:content)
  end

  defp add_dev_layout(content, _ext) do
    content
  end

  defp find_extension(%SourceFile{output_file: output_file}, _preprocessors)
       when not is_nil(output_file) do
    Path.extname(output_file)
  end

  defp find_extension(%SourceFile{input_file: input_file}, preprocessors) do
    preprocessors
    |> Enum.reduce(Path.extname(input_file), fn p, acc ->
      p.extension() || acc
    end)
  end
end
