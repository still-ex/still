alias Still.Compiler.{Incremental, Collections, ErrorCache}

{:ok, _pid} = Still.Compiler.ErrorCache.start_link(%{})
{:ok, _pid} = Incremental.Registry.start_link(%{})
{:ok, _pid} = Collections.start_link(%{})

ExUnit.start()

# Some templating engines need to redefine a module every time a particular
# file is rendered.
Code.compiler_options(ignore_module_conflict: true)
