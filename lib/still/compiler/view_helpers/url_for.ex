defmodule Still.Compiler.ViewHelpers.UrlFor do
  import Still.Utils

  @spec render(String.t()) :: String.t()
  def render(relative_path) do
    relative_path
    |> add_base_url()
  end

  defp add_base_url("/" <> path), do: add_base_url(path)
  defp add_base_url(path), do: get_base_url() <> "/" <> path
end
