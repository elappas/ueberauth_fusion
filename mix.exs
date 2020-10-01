defmodule UeberauthFusion.MixProject do
  use Mix.Project

  @version "0.9.0"
  @url "https://github.com/elappas/ueberauth_fusion"

  def project do
    [
      app: :ueberauth_fusion,
      version: @version,
      name: "Ueberauth Fusion Strategy",
      package: package(),
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      source_url: @url,
      homepage_url: @url,
      description: description(),
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.6.3"},
      {:mock, "~> 0.3", only: :test}
    ]
  end

  defp description do
    "An Uberauth strategy for Fusion auth."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Evangelos Lappas"],
     licenses: ["MIT"],
     links: %{"GitHub": @url}]
  end
end
