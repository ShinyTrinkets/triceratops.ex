defmodule Triceratops.Project.Runner do

  @moduledoc "Module for launching projects."

  require Logger
  alias Triceratops.Project.Manager
  alias Triceratops.Modules.LocalFs
  import Triceratops.Functions, only: :functions

  @doc ~s(Helper function to return the projects path.)
  def projects_path, do: Path.expand "projects/", File.cwd!

  @spec valid_project(charlist) :: boolean
  def valid_project(path), do: String.ends_with?(path, ".json")

  @doc ~s(Initial loading of the projects, on startup.)
  def initial_launch do
    Logger.info ~s(Loading all initial projects ...)
    projects_path
      |> LocalFs.ls_r
      |> Enum.filter(&valid_project/1)
      |> Enum.each(&Manager.load(&1))
  end

  @doc """
  Launches the project, that contains a list of operations
  The first must always be the trigger, the rest are the operations
  """
  @spec launch(atom, list(list)) :: any
  def launch(name, [[trigger|params] | operations]) when
      is_atom(name) and is_binary(trigger) and is_list(params) and is_list(operations) do
    trigger = String.to_atom(trigger)
    # Fix params: the callback should have 1 param: the operations list
    params = [name, hd(params), fn(p) ->
      # All the operations MUST be blocking
      Manager.set_status(name, :running)
      run(operations, p)
      Manager.set_status(name, :pending)
      # The end of current cycle of operations
    end]
    # All function names + modules
    module = Map.get(all_functions, trigger)
    Logger.info "Trigger: #{trigger} #{inspect params}"
    # Triggers need: the project name, the parameters from the parsed project
    # and the callback with the rest of the operations
    Process.flag :trap_exit, true
    # Launch the trigger !!!
    apply module, trigger, params
    # Returns the PID of the trigger
  end


  @doc ~s(Callback that runs all operations, in order.)
  @spec run(list, charlist) :: any
  def run([[op|params] | operations], input) when is_list(operations) and is_binary(input) do
    op = String.to_atom(op)
    params = if length(params) > 0, do: hd(params), else: params
    params = if is_list(params), do: List.to_tuple(params), else: params
    params = [input, params]
    # All function names + modules
    module = Map.get(all_functions, op)
    Logger.info ~s(Operation #{op} #{inspect params} ...)
    # Launch the operation
    result = apply module, op, params
    Logger.info ~s(Operation #{op} result "#{inspect result}".)
    # Repeat cycle
    run operations, result
  end

  @doc ~s(Final run that returns the result.)
  @spec run(list, charlist | none) :: charlist | none
  def run([], result), do: result

  @doc ~s(Helper function that converts a path to an atom with the base file name.)
  @spec path_to_atom(charlist) :: atom
  def path_to_atom(path) do
    path
      |> Path.basename
      |> String.replace_trailing(".json", "")
      |> String.to_atom
  end
end
