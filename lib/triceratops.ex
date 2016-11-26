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
    Triceratops.Application.start
  end
end

defmodule Triceratops.Application do

  @moduledoc "The main supervisor."

  use Supervisor

  def start do
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
