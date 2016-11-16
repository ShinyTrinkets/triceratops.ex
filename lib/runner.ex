defmodule Triceratops.Runner do
  require Logger
  import Triceratops.Functions

  @doc """
  Runs the project, that contains a list of operations
  The first must always be the trigger, the rest are the operations
  """
  @spec run(list(list)) :: any
  def run([[trigger|params] | project]) when is_binary(trigger) and is_list(params) and is_list(project) do
    trigger = String.to_atom(trigger)
    # Fix params: the callback should have 1 param
    params = [hd(params), &(launch(project, &1))]
    # All function names + modules
    module = Map.get(all_functions, trigger)
    Logger.info "Trigger: #{trigger} #{inspect params}"
    # Launch the trigger
    apply module, trigger, params
  end

  @spec launch(list, charlist) :: any
  defp launch([[op|params] | operations], input) when is_list(operations) and is_binary(input) do
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
    launch operations, result
  end

  @spec launch(list, charlist | none) :: charlist | none
  defp launch([], result) do
    result
  end

end
