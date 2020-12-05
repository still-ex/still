{:ok, _} = Still.Compiler.ErrorCache.start_link(%{})
ExUnit.start()

# Some templating engines need to redefine a module every time a particular
# file is rendered.
Code.compiler_options(ignore_module_conflict: true)
