defmodule Triceratops.Project.Manager do

  @moduledoc "Module for managing running projects."

  use GenServer
  require Logger
  alias Poison.Parser
  alias Triceratops.Project.Runner

  @name :project_manager

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def list do
    GenServer.call @name, :list
  end

  def load(path) do
    project = Runner.path_to_atom(path)
    GenServer.cast @name, {:load, project, path}
  end

  def unload(path) do
    project = Runner.path_to_atom(path)
    GenServer.cast @name, {:unload, project}
  end

  def status(project) do
    GenServer.call @name, {:status, project}
  end

  def set_status(project, status) do
    Logger.info ~s(Project "#{project}" status changed to "#{status}".)
    GenServer.call @name, {:status, project, status}
  end

  ### GenServer callbacks ###

  def init(:ok) do
    Logger.info ~s(Started the project manager.)
    {:ok, %{}}
  end

  def handle_call(:list, _from, list) do
    {:reply, list, list}
  end

  def handle_call({:status, project}, _from, list) do
    {:reply, get_in(list, [project, :status]), list}
  end

  def handle_call({:status, project, status}, _from, list) do
    state = Map.get(list, project)
    if state do
      case state.status do
        :restart ->
          Logger.info ~s(Project "#{project}" was scheduled to restart NOW.)
          pid = restart(project, list)
          state = Map.merge(state, %{pid: pid, status: status})
          {:reply, status, Map.put(list, project, state)}
        :shutdown ->
          Logger.info ~s(Project "#{project}" was scheduled to shutdown NOW.)
          Process.exit(state.pid, :shutdown)
          {:reply, :shutdown, Map.delete(list, project)}
        _ ->
          state = Map.put(state, :status, status)
          {:reply, status, Map.put(list, project, state)}
      end
    else
      {:reply, nil, list}
    end
  end

  @doc """
  There are a few operations in LOAD:
  - load a project for the first time
  - if the project is already loaded:
    - if it's pending, reload now
    - if is running, wait for it to finish, then reload
  """
  def handle_cast({:load, project, path}, list) do
    if Map.has_key?(list, project) do
      handle_load_existing(project, path, list)
    else
      pid = launch(project, path)
      state = %{status: :pending, path: path, pid: pid}
      {:noreply, Map.put(list, project, state)}
    end
  end

  def handle_cast({:unload, project}, list) do
    if Map.has_key?(list, project) do
      handle_unload_existing(project, list)
    else
      {:noreply, Map.delete(list, project)}
    end
  end

  # The catch-all clause, that discards any unknown message
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ### Helpers ###

  defp handle_load_existing(project, path, list) do
    if get_in(list, [project, :status]) == :pending do
      Logger.info ~s(Project "#{project}" is reloading NOW.)
      pid = restart(project, path, list)
      state = %{status: :pending, path: path, pid: pid}
      {:noreply, Map.put(list, project, state)}
    else
      Logger.info ~s(Project "#{project}" is scheduled for RESTART.)
      {:noreply, update_in(list, [project, :status], fn(_)->:restart end)}
    end
  end

  defp handle_unload_existing(project, list) do
    if get_in(list, [project, :status]) == :pending do
      Logger.info ~s(Project "#{project}" is shutting down NOW.)
      Process.exit(get_in(list, [project, :pid]), :shutdown)
      {:noreply, Map.delete(list, project)}
    else
      Logger.info ~s(Project "#{project}" is scheduled for SHUTDOWN.)
      {:noreply, update_in(list, [project, :status], fn(_)->:shutdown end)}
    end
  end

  defp launch(project, path) do
    if File.regular?(path) && Path.extname(path) == ".json" do
      operations = Parser.parse! File.read!(path)
      Logger.info "Running project... #{project} => #{inspect operations}"
      Runner.launch project, operations
      # Returns the PID of the trigger
    end
  end

  @spec restart(atom, %{}) :: pid
  defp restart(project, list) do
    restart(project, get_in(list, [project, :path]), list)
  end

  @spec restart(atom, charlist, %{}) :: pid
  defp restart(project, path, list) do
    # Shutdown the old process
    Process.exit(get_in(list, [project, :pid]), :shutdown)
    launch(project, path)
  end
end
