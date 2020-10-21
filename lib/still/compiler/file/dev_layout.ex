defmodule Still.Compiler.File.DevLayout do
  @dev_layout "priv/still/dev.slime"

  alias Still.SourceFile

  def wrap(children) do
    content =
      Application.app_dir(:still, @dev_layout)
      |> File.read!()

    Still.Preprocessor.Slime.run(%SourceFile{
      input_file: @dev_layout,
      content: content,
      variables: %{children: children, file_path: @dev_layout}
    })
  end
end
