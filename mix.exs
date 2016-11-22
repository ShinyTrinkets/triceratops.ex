defmodule Triceratops.Mixfile do
  use Mix.Project

  def project do
    [app: :triceratops,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: escript,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [
      :logger, :logger_file_backend, :porcelain, :fs, :filesmasher, :bamboo, :bamboo_smtp]
    ]
  end

  def escript do
    [main_module: Triceratops]
  end

  defp deps do
    [
      {:logger_file_backend, "~> 0.0"},
      {:poison, "~> 3.0"},
      {:porcelain, "~> 2.0"},
      {:fs, github: "synrc/fs"},
      {:filesmasher, github: "croqaz/FileSmasher"},
      {:bamboo_smtp, "~> 1.2"},
      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
