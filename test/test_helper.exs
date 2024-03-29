alias Still.Compiler
alias Still.Compiler.{Incremental, Collections}
alias Still.Data

{:ok, _} = Application.ensure_all_started(:timex)
{:ok, _} = Application.ensure_all_started(:cachex)

{:ok, _pid} =
  Registry.start_link(keys: :unique, name: Compiler.Incremental.OutputToInputFileRegistry)

{:ok, _pid} = Incremental.Registry.start_link(%{})
{:ok, _pid} = Collections.start_link(%{})
{:ok, _pid} = Data.start_link([])
{:ok, _pid} = Cachex.start_link(name: Still.Compiler.ContentCache.cache_name())

ExUnit.start()

# Some templating engines need to redefine a module every time a particular
# file is rendered.
Code.compiler_options(ignore_module_conflict: true)
