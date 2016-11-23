defmodule Triceratops.Project.Watcher do

  @moduledoc "Module for watching the projects folder."

  use GenServer
  require Logger
  import Poison.Parser, only: :functions
  import Triceratops.Project.Runner, only: :functions

  @projects_path Path.expand("projects/")

  @doc ~s(Watch the projects directory.)
  def watch_projects do
    {:ok, _pid} = :fs.start_link(:fs_watcher, @projects_path)
    GenServer.start_link(__MODULE__, [], name: :project_manager)
  end

  ### GenServer callbacks ###

  def init(state) do
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

  defp handle_events(path, events) do
    atom_project = project_to_atom(path)
    # Decide what to do with the event
    cond do
      :created in events && :modified in events ->
        Logger.info ~s(New project: #{atom_project}.)
      :modified in events ->
        Logger.info ~s(Changed project: #{atom_project}.)
      :renamed in events && File.regular?(path) ->
        Logger.info ~s(Renamed project: #{atom_project}.)
      :renamed in events ->
        Logger.info ~s(Deleted project: #{atom_project}.)
    end
    operations = parse! File.read!(path)
    Logger.info "Running project... #{inspect operations}"
    launch atom_project, operations
  end

  defp project_to_atom(project) do
    project
      |> Path.basename
      |> String.replace_trailing(".json", "")
      |> String.to_atom
  end
end
