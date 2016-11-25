defmodule Triceratops.Project.Watcher do

  @moduledoc """
  Module for watching the projects folder.
  This requires that "fswatch" is already installed.
  """

  require Logger
  alias Triceratops.Project.Runner
  alias Triceratops.Project.Manager

  @name :project_watcher

  def start_link do
    FsWatch.start_link name: @name, folder: Runner.projects_path,
      callback: fn({path, events}) ->
        if Runner.valid_project(path), do: handle_changes(path, events)
      end
  end

  @spec handle_changes(charlist, list(atom)) :: any
  def handle_changes(path, events) do
    file = Path.basename(path)
    # Decide what to do with the event
    cond do
      :renamed in events ->
        if File.regular?(path) do
          Logger.info ~s(Renamed/moved project file "#{file}".)
          Manager.load(path)
        else
          Logger.info ~s(Deleted project file "#{file}".)
          Manager.unload(path)
        end
      :created in events ->
        Logger.info ~s(New project file "#{file}".)
        Manager.load(path)
      :updated in events ->
        Logger.info ~s(Changed project file "#{file}".)
        Manager.load(path)
    end
  end
end
