defmodule Still.Compiler.ViewHelpers.SafeHTML do
  def render(nil), do: ""

  def render(content) when is_atom(content) do
    content
    |> Atom.to_string()
    |> Plug.HTML.html_escape()
  end

  def render(content) when is_bitstring(content) do
    Plug.HTML.html_escape(content)
  end

  def render(content) when is_list(content) do
    content
    |> Stream.map(&render/1)
    |> Enum.join(", ")
  end

  def render(content) when is_integer(content) do
    Integer.to_string(content)
  end

  def render(content) when is_float(content) do
    Float.to_string(content)
  end

  def render(%Time{} = t), do: Time.to_string(t)
  def render(%Date{} = d), do: Date.to_string(d)
  def render(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_string(ndt)
  def render(%DateTime{} = dt), do: dt |> DateTime.to_string() |> render()

  def render({:safe, data}), do: data

  def render(term) do
    raise ArgumentError, "cannot render safe HTML for #{inspect(term)}"
  end
end
