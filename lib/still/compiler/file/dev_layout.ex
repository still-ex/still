defmodule Still.Compiler.File.DevLayout do
  @dev_layout "priv/still/dev.slime"

  def wrap(content) do
    %{content: content} =
      Application.app_dir(:still, @dev_layout)
      |> File.read!()
      |> Still.Preprocessor.Slime.run(%{children: content, file_path: @dev_layout})

    content
  end
end
