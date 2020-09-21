defmodule Mix.Still.Project do
  defstruct [:name, :module, :path, :version]

  @still_version Mix.Project.config()[:version]

  def new(opts) do
    %__MODULE__{
      name: Keyword.fetch!(opts, :name),
      module: to_module_name(opts[:module] || opts[:name]),
      path: ensure_path(opts[:path] || "./#{opts[:name]}"),
      version: @still_version
    }
  end

  defp ensure_path(path) do
    if String.ends_with?(path, "/") do
      path
    else
      path <> "/"
    end
  end

  defp to_module_name(name) do
    name
    |> String.split(["-", "_"], trim: true)
    |> Stream.map(&upcase_first_letter/1)
    |> Enum.join("")
  end

  defp upcase_first_letter(<<head::utf8, tail::binary>>) do
    String.upcase(<<head::utf8>>) <> tail
  end
end
