defmodule Cldr.Html.MixProject do
  use Mix.Project

  @version "1.5.2"

  def project do
    [
      app: :cldr_html,
      version: @version,
      elixir: "~> 1.10",
      compilers: Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Cldr HTML",
      description: description(),
      source_url: "https://github.com/elixir-cldr/cldr_html",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps:
          ~w(ex_cldr cldr_utils decimal ex_cldr_numbers ex_money ex_cldr_units ex_cldr_territories ex_cldr_locale_display ex_cldr_currencies)a
      ]
    ]
  end

  defp description do
    """
    HTML helper functions for the Common Locale Data
    Repository (CLDR).
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
      links: links(),
      files: [
        "lib",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      logo: "logo.png",
      skip_undefined_reference_warnings_on: ["changelog", "CHANGELOG.md"]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/elixir-cldr/cldr_html",
      "Readme" => "https://github.com/elixir-cldr/cldr_html/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/elixir-cldr/cldr_html/blob/v#{@version}/CHANGELOG.md"
    }
  end

  defp deps do
    [
      {:ex_cldr_currencies, "~> 2.15", optional: true},
      {:ex_cldr_territories, "~> 2.8", optional: true},
      {:ex_cldr_units, "~> 3.16", optional: true},
      {:ex_cldr_locale_display, "~> 1.4", optional: true},
      {:ex_cldr_collation, "~> 0.5", optional: true},
      {:ex_money, "~> 5.13", optional: true},
      {:phoenix_html, "~> 1.2 or ~> 2.0 or ~> 3.0"},
      {:jason, "~> 1.0", optional: true},
      {:poison, "~> 2.1 or ~> 3.0 or ~> 4.0", optional: true},
      {:ex_doc, "~> 0.18", only: [:dev, :test, :release], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "src", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "src", "bench"]
  defp elixirc_paths(_), do: ["lib", "src"]
end
