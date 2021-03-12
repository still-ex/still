defmodule Still.Compiler.File.DevLayout do
  @moduledoc """
  Responsible for wrapping a portion of markup in a pre-defined development
  layout and compiling the output. Should only be used in a `dev` environment.

  The development layout used is in `priv/still/dev.slime` and handles the
  styling of errors and subscribing to file updates, causing the browser to
  refresh.
  """

  @dev_layout "priv/still/dev.slime"

  alias Still.SourceFile

  @doc """
  Wraps the given content in a `Still.SourceFile` containing the development
  layout as input and the content as children.
  """
  def wrap(children) do
    content =
      Application.app_dir(:still, @dev_layout)
      |> File.read!()

    Still.Preprocessor.Slime.run(
      %SourceFile{
        input_file: @dev_layout,
        content: content,
        metadata: %{children: children, file_path: @dev_layout}
      },
      []
    )
  end
end
