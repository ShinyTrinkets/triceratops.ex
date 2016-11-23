defmodule Triceratops.Project.Runner do

  @moduledoc "Module for launching projects."

  require Logger
  import Triceratops.Functions, only: :functions

  @doc """
  Launches the project, that contains a list of operations
  The first must always be the trigger, the rest are the operations
  """
  @spec launch(atom, list(list)) :: any
  def launch(name, [[trigger|params] | operations]) when
      is_atom(name) and is_binary(trigger) and is_list(params) and is_list(operations) do
    trigger = String.to_atom(trigger)
    # Fix params: the callback should have 1 param: the operations list
    params = [name, hd(params), &(run(operations, &1))]
    # All function names + modules
    module = Map.get(all_functions, trigger)
    Logger.info "Trigger: #{trigger} #{inspect params}"
    # Triggers need: the project name, the parameters from the parsed project
    # and the callback with the rest of the operations
    # Launch the trigger !!!
    apply module, trigger, params
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
    Logger.info "Operation: #{op} #{inspect params}"
    # Launch the operation
    result = apply module, op, params
    # Repeat cycle
    run operations, result
  end

  @doc ~s(Final call that returns the result.)
  @spec run(list, charlist | none) :: charlist | none
  def run([], result) do
    Logger.info "Finished a project! Result = #{inspect result}"
    result
  end
end
