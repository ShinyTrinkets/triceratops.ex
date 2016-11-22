defmodule Triceratops.Project.Watcher do

  @moduledoc "Module for watching the projects folder."

  use GenServer
  require Logger
  import Poison.Parser, only: :functions
  # import Triceratops.Project.Runner, only: :functions

  @projects_path Path.expand("projects/")

  @doc "Watch a specified directory."
  def watch_projects do
    GenServer.start_link(__MODULE__, [], name: :project_watcher)
  end

  ### GenServer callbacks ###

  def init(state) do
    {:ok, _pid} = :fs.start_link(:fs_watcher, @projects_path)
    :fs.subscribe(:fs_watcher)
    Logger.info ~s(Started watching "#{@projects_path}" folder for changes.)
    {:ok, state}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, events}}, state) do
    spawn fn ->
      Logger.info ~s(Projects folder changed: #{path} :: #{inspect events})
      handle_events(path, events)
    end
    {:noreply, state}
  end

  ### Helpers ###

  def handle_events(path, events) do
    p_path = Path.basename(path)
    cond do
      :created in events && :modified in events ->
        Logger.info ~s(New project: #{p_path}.)
      :modified in events ->
        Logger.info ~s(Changed project: #{p_path}.)
      :renamed in events && File.regular?(path) ->
        Logger.info ~s(Renamed project: #{p_path}.)
      :renamed in events ->
        Logger.info ~s(Deleted project: #{p_path}.)
    end
    operations = parse! File.read! "./project.json"
    Logger.info "Running project... #{inspect operations}"
    # launch operations
  end
end
