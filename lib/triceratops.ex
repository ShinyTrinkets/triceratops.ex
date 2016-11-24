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

  def main(_) do
    Logger.info "Warming up..."
    # ...
    Logger.info "Shutting down..."
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
