defmodule Triceratops.Modules.Filters do

  @doc """
  Filter 1 or more files or folders, based on their type and name
  """
  @spec file_filter(binary | list, {atom, charlist}) :: binary | list(charlist)
  def file_filter(input, {type, expr}) do
    cond do
      is_list(input) ->
        Enum.filter(input, fn(f) -> file_filter_callback(f, type, expr) end)
      is_binary(input) ->
        case file_filter_callback(input, type, expr) do
          true -> input
          false -> nil
        end
      true -> raise "Invalid input type!"
    end
  end

  @spec file_filter_callback(charlist, atom, charlist) :: boolean
  defp file_filter_callback(input, type, expr) do
    type_check = case type do
      :file -> File.regular?(input)
      :folder -> File.dir?(input)
      _ -> File.exists?(input)
    end
    {:ok, regex} = Regex.compile(expr)
    re_check = Regex.match?(regex, input)
    type_check && re_check
  end
end
