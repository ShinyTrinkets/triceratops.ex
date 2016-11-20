defmodule Triceratops.Modules.Filters do

  @moduledoc "Module for filtering file and folder names."

  @doc "Filter 1 or more files or folders, based on their type and name."
  @spec file_filter(any, {charlist, charlist}) :: any
  def file_filter(input, {type, expr}) when is_binary(type),
    do: file_filter(input, {String.to_atom(type), expr})

  @spec file_filter(list(charlist), {atom, charlist}) :: list(charlist)
  def file_filter(input, {type, expr}) when is_list(input),
    do: Enum.filter(input, fn(f) -> file_filter_callback(f, type, expr) end)

  @spec file_filter(charlist, {atom, charlist}) :: charlist
  def file_filter(input, {type, expr}) when is_binary(input) do
    if file_filter_callback(input, type, expr), do: input, else: nil
  end

  @spec file_filter_callback(charlist, atom, charlist) :: boolean
  defp file_filter_callback(input, type, expr) when type in [:file, :folder, :any] do
    type_check = case type do
      :file -> File.regular?(input)
      :folder -> File.dir?(input)
      :any  -> File.exists?(input)
    end
    {:ok, regex} = Regex.compile(expr)
    re_check = Regex.match?(regex, input)
    type_check && re_check
  end
end
