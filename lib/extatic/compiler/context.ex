defmodule Extatic.Compiler.Context do
  defmodule Type do
    defstruct preprocessor: nil,
              input_file: nil,
              output_file: nil,
              variables: %{}
  end

  use GenServer

  alias __MODULE__.Type, as: Context

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def push(input_file, output_file, preprocessor) do
    GenServer.cast(__MODULE__, {:push, input_file, output_file, preprocessor})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def add_variable(variable, value) do
    GenServer.cast(__MODULE__, {:add_var, variable, value})
  end

  def get_variable(variable) do
    GenServer.call(__MODULE__, {:get_var, variable})
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast({:push, input_file, output_file, preprocessor}, stack) do
    context = %Context{
      input_file: input_file,
      output_file: output_file,
      preprocessor: preprocessor
    }

    {:noreply, [context | stack]}
  end

  def handle_cast({:add_var, var, val}, [%{variables: variables} = h | t]) do
    variables = Map.put(variables, var, val)

    {:noreply, [%{h | variables: variables} | t]}
  end

  def handle_call(:pop, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:pop, _from, [h | t]) do
    {:reply, h, t}
  end

  def handle_call({:get_var, var}, _from, [%{variables: variables} | _] = stack) do
    {:reply, Map.fetch!(variables, var), stack}
  end
end
