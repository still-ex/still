defmodule Still.New.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :still_new,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger, :eex]]
  end

  defp deps do
    []
  end

  defp aliases do
    [build: [&build_releases/1]]
  end

  defp build_releases(_) do
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run([])
    Mix.Tasks.Archive.Build.run(["--output=still_new.ez"])
    File.rename("still_new.ez", "./archives/still_new.ez")
    File.rename("still_new-#{@version}.ez", "./archives/still_new-#{@version}.ez")
  end
end
