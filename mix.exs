defmodule Cldr.Html.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :cldr_html,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_cldr, "~> 2.18"},
      {:phoenix_html, "~> 1.2 or ~> 2.0"},
      {:ex_cldr_currencies, "~> 2.8", optional: true},
      {:ex_money, "~> 3.0", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:poison, "~> 2.1 or ~> 3.0", optional: true},
      {:ex_doc, "~> 0.18", only: :dev},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "src", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "src", "bench"]
  defp elixirc_paths(_), do: ["lib", "src"]
end
