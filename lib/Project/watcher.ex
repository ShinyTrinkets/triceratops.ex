defmodule Triceratops.Project.Watcher do

  @moduledoc "Module for watching the projects folder."

  use GenServer
  require Logger
  alias Triceratops.Project.Manager

  @name :project_watcher
  @projects_path Path.expand("projects/")

  def start_link do
    {:ok, _} = Sentix.start_link :fs_watcher, [@projects_path]
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  ### GenServer callbacks ###

  def init(:ok) do
    Sentix.subscribe(:fs_watcher)
    Logger.info ~s(Started watching "#{@projects_path}" folder for changes.)
    {:ok, []}
  end

  def handle_info({_pid, {:fswatch, :file_event}, {path, events}}, state) do
    path = to_string(path)
    Logger.info ~s(File changed: #{path} :: #{inspect events})
    if Path.extname(path) == ".json" do
      handle_events(path, events)
    end
    {:noreply, state}
  end

  # The catch-all clause, that discards any unknown message
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ### Helpers ###

  defp handle_events(path, events) do
    file = Path.basename(path)
    # Decide what to do with the event
    cond do
      :created in events ->
        Logger.info ~s(New project file "#{file}".)
        Manager.load(path)
      :updated in events ->
        Logger.info ~s(Changed project file "#{file}".)
        Manager.load(path)
      :renamed in events && File.regular?(path) ->
        Logger.info ~s(Renamed/moved project file "#{file}".)
        Manager.load(path)
      :renamed in events ->
        Logger.info ~s(Deleted project file "#{file}".)
        Manager.unload(path)
    end
  end
end
