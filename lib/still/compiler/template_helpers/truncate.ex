defmodule Still.Compiler.TemplateHelpers.Truncate do
  @moduledoc """
  Truncates the content to a given maximum.

  ## Options

  * `length` - Maximum length of the truncated string. This includes the
  omission string. Defaults to `300`.
  * `omission` - String to indicate the omission of further text. Defaults to
  `"..."`
  """

  @default_length 300
  @default_omission "..."

  def render(str, opts \\ []) do
    length = opts[:length] || @default_length
    omission = opts[:omission] || @default_omission

    exceeding_size?(str, length)
    minimum_size?(omission, length)

    if exceeding_size?(str, length) and minimum_size?(omission, length) do
      slicing_len = length - String.length(omission)
      String.slice(str, 0, slicing_len) <> omission
    else
      str
    end
  end

  defp exceeding_size?(str, length),
    do: String.length(str) > length

  # This case is hard to document but happens when you try to truncate
  # a string like "aa", giving a max length of 1.
  # The resulting truncated string would be larger than the original:
  # "aa" vs "a...".
  #
  # This check prevents that scenario
  defp minimum_size?(omission, length),
    do: length - String.length(omission) > 0
end
