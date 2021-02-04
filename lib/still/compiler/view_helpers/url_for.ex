defmodule Still.Compiler.ViewHelpers.UrlFor do
  @moduledoc """
  Converts a relative path to an absolute path.
  """
  import Still.Utils

  @doc """
  Converts the given relative path to an absolute path by prepending the
  application's base URL and removing references to `index.html`.
  """
  @spec render(String.t()) :: String.t()
  def render(relative_path) do
    relative_path
    |> add_base_url()
    |> clean_url()
  end

  defp add_base_url("/" <> path), do: add_base_url(path)
  defp add_base_url(path), do: get_base_url() <> "/" <> path

  defp clean_url(path) do
    path |> String.replace_suffix("index.html", "")
  end
end
