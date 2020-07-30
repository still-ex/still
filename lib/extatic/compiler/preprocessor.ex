defmodule Extatic.Compiler.Preprocessor do
  alias Extatic.Compiler.Preprocessor

  @supported_preprocessors %{
    ".slim" => Preprocessor.Slime,
    ".slime" => Preprocessor.Slime,
    ".eex" => Preprocessor.EEx
  }

  def for(file) do
    extension = Path.extname(file)

    @supported_preprocessors[extension] ||
      raise CompileError, message: "unsupported file extension in #{file}"
  end
end
