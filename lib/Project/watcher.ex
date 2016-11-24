defmodule Triceratops.Project.Watcher do

  @moduledoc "Module for watching the projects folder."

  use GenServer
  require Logger
  alias Triceratops.Project.Manager

  @name :project_watcher
  @projects_path Path.expand("projects/")

  def start_link do
    {:ok, _} = :fs.start_link(:fs_watcher, @projects_path)
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  ### GenServer callbacks ###

  def init(:ok) do
    :fs.subscribe(:fs_watcher)
    Logger.info ~s(Started watching "#{@projects_path}" folder for changes.)
    {:ok, []}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, events}}, list) do
    path = to_string(path)
    Logger.info ~s(File changed: #{path} :: #{inspect events})
    if Path.extname(path) == ".json" do
      handle_events(path, events)
    end
    {:noreply, list}
  end

  ### Helpers ###

  defp handle_events(path, events) do
    file = Path.basename(path)
    # Decide what to do with the event
    cond do
      :created in events ->
        Logger.info ~s(New project file "#{file}".)
        Manager.load(path)
      :modified in events ->
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
