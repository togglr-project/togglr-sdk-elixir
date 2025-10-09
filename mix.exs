defmodule TogglrSdk.MixProject do
  use Mix.Project

  def project do
    [
      app: :togglr_sdk,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/togglr-project/togglr-sdk-elixir",
      homepage_url: "https://github.com/togglr-project/togglr-sdk-elixir",
      docs: [
        main: "TogglrSdk",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.15.3"},
      {:jason, "~> 1.4"},
      {:cachex, "~> 3.6"},
      {:telemetry, "~> 1.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:hackney, "~> 1.25"}
    ]
  end

  defp description do
    "Official Elixir SDK for Togglr feature flag management system"
  end

  defp package do
    [
      maintainers: ["Togglr Team"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/togglr-project/togglr-sdk-elixir",
        "Documentation" => "https://hexdocs.pm/togglr_sdk"
      }
    ]
  end
end
