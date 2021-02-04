defmodule Still.New.Generator do
  @root Path.expand("../../..", __DIR__)

  def run(project) do
    for {input, output} <- template_files(project),
        do: copy_file(input, output, project)
  end

  defp template_files(project) do
    [
      {"config/config.exs", "config/config.exs"},
      {"config/dev.exs", "config/dev.exs"},
      {"config/prod.exs", "config/prod.exs"},
      {"config/test.exs", "config/test.exs"},
      {"lib/app_name.ex", "lib/#{project.name}.ex"},
      {"priv/site/index.slime", "priv/site/index.slime"},
      {"formatter.exs", ".formatter.exs"},
      {"gitignore", ".gitignore"},
      {"mix.exs", "mix.exs"}
    ]
  end

  defp copy_file(input, output, project) do
    input_path = template_path(input)
    output_path = project.path <> output
    metadata = eex_metadata(project)

    Mix.Generator.copy_template(input_path, output_path, metadata)
  end

  defp template_path(input) do
    "#{@root}/templates/#{input}"
  end

  defp eex_metadata(project) do
    [
      app_module: project.module,
      app_name: project.name,
      still_version: project.version
    ]
  end
end
