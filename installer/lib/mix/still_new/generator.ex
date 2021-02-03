defmodule Still.New.Generator do
  @root Path.expand("../../..", __DIR__)

  def run(project) do
    ensure_base_path_exists(project)
    copy_template(project)
  end

  defp copy_template(project) do
    for {input, output} <- template_files(project),
        do: copy_file(input, output, project)
  end

  defp template_files(project) do
    [
      {"config/config.exs", "config/config.exs"},
      {"lib/app_name.ex", "lib/#{project.name}.ex"},
      {"priv/site/index.slime", "priv/site/index.slime"},
      {"formatter.exs", ".formatter.exs"},
      {"gitignore", ".gitignore"},
      {"mix.exs", "mix.exs"}
    ]
  end

  defp copy_file(input, output, project) do
    input_path = template_path(input)
    output_path = output_path(project, output)
    metadata = eex_metadata(project)

    Mix.Generator.copy_template(input_path, output_path, metadata)
  end

  defp template_path(input) do
    "#{@root}/templates/#{input}"
  end

  defp output_path(project, output) do
    (project.path <> output)
    |> Path.expand()
  end

  defp eex_metadata(project) do
    [
      app_module: project.module,
      app_name: project.name,
      still_version: project.version
    ]
  end

  defp ensure_base_path_exists(%{path: path}) do
    cwd = File.cwd!()
    target = path |> Path.expand() |> Path.dirname()

    if cwd == target do
      true
    else
    path
    |> Path.expand()
    |> Path.dirname()
    |> Mix.Generator.create_directory()
    end
  end
end
