defmodule Mix.Tasks.Still.New do
  @moduledoc """
  Creates a new Still project.

  Expects the project name as an argument.

      mix still.new my_site [--path PATH] [--module MODULE]

  ## Options

  * `--path` - path where the project should be created.
  * `--module` - name of the base module to be generated.
  """

  use Mix.Task

  @arg_types [
    path: :string,
    module: :string
  ]

  alias Still.New.{Generator, Project}

  @doc false
  def run(args) do
    case parse_opts(args) do
      {nil, []} ->
        Mix.Tasks.Help.run(["still.new"])

      {name, opts} ->
        Project.new([{:name, name} | opts])
        |> Generator.run()
    end
  end

  defp parse_opts(args) do
    case OptionParser.parse(args, strict: @arg_types) do
      {opts, [name], []} ->
        {name, opts}

      {_, [], []} ->
        {nil, []}

      {_, args, []} ->
        Mix.raise("Invalid project name: #{Enum.join(args, " ")}")

      {_opts, _args, [{arg, nil} | _]} ->
        Mix.raise("Invalid argument: #{arg}")

      {_opts, _args, [{arg, value} | _]} ->
        Mix.raise("Invalid argument: #{arg}=#{value}")
    end
  end
end
