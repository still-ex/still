defmodule Still.ViewHelper do
  @callback __still_view_helper__ :: :ok

  defmacro __using__(_) do
    quote do
      @behaviour Still.ViewHelper

      def __still_view_helper__, do: :ok
    end
  end
end
