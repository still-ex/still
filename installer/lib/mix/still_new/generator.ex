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
    with :ok <- ensure_file_path_exists(project, output),
         content <- read_file(input),
         transformed <- process_eex(project, content),
         :ok <- write_project_file(project, output, transformed) do
      :ok
    end
  end

  defp read_file(input) do
    File.read!("#{@root}/templates/#{input}")
  end

  defp write_project_file(project, output, content) do
    (project.path <> output)
    |> Path.expand()
    |> File.write!(content)
  end

  defp process_eex(project, content) do
    variables = project_to_eex_variables(project)

    EEx.eval_string(content, variables)
  end

  defp project_to_eex_variables(project) do
    [
      app_module: project.module,
      app_name: project.name,
      still_version: project.version
    ]
  end

  defp ensure_base_path_exists(project) do
    ensure_path_exists(project.path)
  end

  defp ensure_file_path_exists(project, path) do
    ensure_path_exists(project.path <> path)
  end

  def ensure_path_exists(path) do
    path
    |> Path.expand()
    |> Path.dirname()
    |> File.mkdir_p()
  end
end
