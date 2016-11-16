defmodule Triceratops.Runner do
  import Triceratops.Functions

  @doc """
  The head must always be the trigger function, the rest are the operations
  """
  @spec run(list(list)) :: any
  def run([trigger | project]) when is_list(trigger) and is_list(project) do
    # Get the trigger name and the params
    [trigger | [trigger_params|_]] = trigger
    # Trigger must be an atom
    trigger = String.to_atom(trigger)
    # The trigger calls the callback with 1 param
    trigger_params = [trigger_params, fn(path) ->
      launch(project, path)
    end]
    # All function names + modules
    module = Map.get(all_functions, trigger)
    IO.puts "Trigger: #{module}.#{trigger} #{inspect trigger_params}"
    # Launch the trigger
    apply module, trigger, trigger_params
  end

  @spec launch(list, charlist) :: any
  defp launch([[op|params] | operations], input) when is_list(operations) and is_binary(input) do
    op = String.to_atom(op)
    params = if length(params) > 0, do: hd(params), else: params 
    params = if is_list(params), do: List.to_tuple(params), else: params
    params = [input, params]
    # All function names + modules
    module = Map.get(all_functions, op)
    IO.puts "Operation: #{module}.#{op} #{inspect params}"
    # Launch the operation
    result = apply module, op, params
    launch operations, result
  end

  @spec launch(list, charlist | none) :: charlist | none
  defp launch([], result) do
    result
  end

end
