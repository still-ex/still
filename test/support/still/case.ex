defmodule Still.Case do
  use ExUnit.CaseTemplate

  def ensure_clean_error_cache do
    case Still.Compiler.ErrorCache.start_link(%{}) do
      {:ok, _} -> :ok
      _error -> Still.Compiler.ErrorCache.clear()
    end
  end

  using do
    quote do
      alias Still.Compiler.ErrorCache

      import Still.Utils

      setup do
        Application.put_env(:still, :pass_through_copy, [])
        Still.Compiler.Collections.reset()
        Still.Utils.clean_output_dir()
        Still.Case.ensure_clean_error_cache()

        preprocessors = Application.get_env(:still, :preprocessors) || %{}

        on_exit(fn ->
          Application.put_env(:still, :preprocessors, preprocessors)
        end)

        :ok
      end
    end
  end
end
