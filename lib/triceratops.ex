defmodule Triceratops do

  @moduledoc "The main module."

  use Application
  require Logger

  @on_load :on_load
  def on_load do
    log = Application.get_env(:logger, :info)[:path]
    if File.regular?(log), do: File.rm(log)
    :ok
  end

  def start(_type, _args) do
    Triceratops.Supervisor.start_link
  end
end


defmodule Triceratops.Supervisor do

  @moduledoc "The main supervisor."

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Triceratops.Project.Watcher, []),
      worker(Triceratops.Project.Manager, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end


defmodule Triceratops.CLI do

  @moduledoc "The escript build application."

  require Logger

  defp forever_sleep do
    Process.sleep(250)
    forever_sleep
  end

  def main(args \\ []) do
    {opts, _, _} = OptionParser.parse(args, aliases: [h: :help])
    if opts == [help: true] do
      {_, _, version} = List.first :application.which_applications
      IO.puts """
      \nTriceratops version: #{version};
      """
    else
      Logger.info "Warming up..."
      Triceratops.Supervisor.start_link
      Process.sleep(250)
      Triceratops.Project.Runner.initial_launch
      forever_sleep
      Logger.info "Shutting down..."
    end
  end
end
