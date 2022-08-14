defmodule Still.Preprocessor.RequestedOutputFile do
  @moduledoc """
  Filters out files that are not the one being requested.

  This preprocessor is helpful during development when the user is requesting a page.
  Still identifies the input file that generates the file being requested by the user,
  but that input file can generate multiple output files (for instance, files that use pagination).
  Those extra pages being compiled will not be delivered to the client.
  This extension uses the `:requested_output_file` attribute to identify the file being requested, and filters out all others.
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(
        %{
          output_file: output_file,
          requested_output_file: requested_output_file,
          run_type: :compile_dev
        } = source_file
      )
      when not is_nil(output_file) and not is_nil(requested_output_file) do
    cond do
      output_file ==
          requested_output_file ->
        source_file

      true ->
        []
    end
  end

  def render(source_file) do
    source_file
  end
end
