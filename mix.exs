defmodule Triceratops.Mixfile do
  use Mix.Project

  def project do
    [app: :triceratops,
     version: "0.1.1",
     elixir: "~> 1.3",
     escript: escript,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [
      :logger, :logger_file_backend, :porcelain, :fswatch, :filesmasher, :bamboo, :bamboo_smtp]
    ]
  end

  def escript do
    [main_module: Triceratops.Util.CLI]
  end

  defp deps do
    [
      {:logger_file_backend, "~> 0.0"},
      {:temp, "~> 0.4"},
      {:poison, "~> 3.0"},
      {:porcelain, "~> 2.0"},
      {:fswatch, github: "croqaz/FsWatch"},
      {:filesmasher, github: "croqaz/FileSmasher"},
      {:bamboo_smtp, "~> 1.2"},
      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
