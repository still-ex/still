defmodule Still.Compiler.Compile do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def run do
    GenServer.call(__MODULE__, :run, :infinity)
  end

  def on_compile(fun) do
    GenServer.cast(__MODULE__, {:on_compile, fun})
  end

  def init(_opts) do
    {:ok, %{hooks: []}}
  end

  def handle_call(:run, _from, state) do
    Still.Compiler.Traverse.run()
    Still.Compiler.Traverse.run()

    all_waiting(state.hooks)
    |> Enum.uniq()
    |> Enum.each(fn
      {mod, fun, args} -> apply(mod, fun, args)
      fun when is_function(fun, 0) -> fun.()
      _ -> :ok
    end)

    {:reply, :ok, state}
  end

  def handle_cast({:on_compile, fun}, state) do
    hooks = [fun | state.hooks]

    {:noreply, %{state | hooks: hooks}}
  end

  defp all_waiting(acc) do
    receive do
      {:"$gen_cast", {:on_compile, fun}} -> all_waiting([fun | acc])
    after
      0 -> acc
    end
  end
end
