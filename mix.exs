defmodule Pillar.MixProject do
  use Mix.Project

  @source_url "https://github.com/balance-platform/pillar"
  @version "0.37.0"

  def project do
    [
      app: :pillar,
      name: "Pillar",
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      description: description(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      homepage_url: @source_url,
      docs: docs()
    ]
  end

  def application, do: [extra_applications: []]

  defp deps do
    [
      {:tesla, "~> 1.14"},
      {:mint, "~> 1.7"},
      {:castore, "~> 1.0"},
      {:poolboy, "~> 1.5"},
      {:decimal, "~> 2.3"},

      # testing and development
      {:tzdata, "~> 1.1", only: [:dev, :test]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.16", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.18", only: [:test], runtime: false}
    ]
  end

  defp description do
    """
    Elixir client for ClickHouse, a fast open-source Online Analytical
    Processing (OLAP) database management system.
    """
  end

  defp package do
    [
      name: "pillar",
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
