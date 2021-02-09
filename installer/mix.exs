defmodule Still.New.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :still_new,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        licenses: ["ISC"],
        links: %{"GitHub" => "https://github.com/still-ex/still"},
        files: ~w(lib priv mix.exs README.md)
      ],
      description: """
      Still project generator.

      Provides a `mix still.new` task to bootstrap a new Still project.
      """
    ]
  end

  def application do
    [extra_applications: [:logger, :eex]]
  end

  defp deps do
    []
  end
end
