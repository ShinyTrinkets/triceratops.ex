defmodule Triceratops.Project.Manager do

  @moduledoc "Module for managing running projects."

  use GenServer
  require Logger
  alias Poison.Parser
  # alias Triceratops.Project.Runner

  @name :project_manager

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def list do
    GenServer.call @name, :list
  end

  def load(project, path) do
    GenServer.cast @name, {:load, project, path}
  end

  def unload(project) do
    GenServer.cast @name, {:unload, project}
  end

  def state(project) do
    GenServer.call @name, {:state, project}
  end

  ### GenServer callbacks ###

  def init(:ok) do
    Logger.info ~s(Started the project manager.)
    {:ok, %{}}
  end

  def handle_call(:list, _from, list) do
    {:reply, list, list}
  end

  def handle_call({:state, project}, _from, list) do
    {:reply, Map.get(list, project), list}
  end

  def handle_cast({:load, project, path}, list) do
    if Map.has_key?(list, project) do
      {:noreply, list}
    else
      list = Map.put(list, project, %{status: :pending, path: path})
      launch(project, path)
      {:noreply, list}
    end
  end

  def handle_cast({:unload, project}, list) do
    {:noreply, Map.delete(list, project)}
  end

  ### Helpers ###

  defp launch(project, path) do
    if File.regular?(path) && Path.extname(path) == ".json" do
      operations = Parser.parse! File.read!(path)
      Logger.info "Running project... #{project} => #{inspect operations}"
      # Runner.launch project, operations
    end
  end
end
