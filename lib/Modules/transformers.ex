defmodule Triceratops.Modules.LocalFs do
  import Triceratops.Helpers

  def file_copy(input, output) when is_list(input) do
    IO.puts ~s(Copying #{length(input)} files...)
    Enum.map(input, fn(f) -> file_copy(f, output) end)
  end

  def file_copy(input, output) when is_binary(input) do
    output = fix_output(input, output)
    # Copies the contents in source to destination preserving its mode
    :ok = File.cp!(input, output)
    IO.puts ~s(Copied file "#{input}" into "#{output}".)
    output # return the output for next operation
  end


  def file_move(input, output) when is_list(input) do
    IO.puts ~s(Moving #{length(input)} files...)
    Enum.map(input, fn(f) -> file_move(f, output) end)
  end

  def file_move(input, output) when is_binary(input) do
    output = fix_output(input, output)
    # Renames the source file to destination file
    :ok = File.rename(input, output)
    IO.puts ~s(Moved file "#{input}" in "#{output}".)
    output # return the output for next operation
  end


  def delete_file(input) when is_list(input) do
    IO.puts ~s(Deleting #{length(input)} files...)
    Enum.map(input, fn(f) -> delete_file(f) end)
  end

  def delete_file(input) when is_binary(input) do
    # Tries to delete the file path
    :ok = File.rm!(input)
    IO.puts ~s(Deleted file "#{input}".)
    nil # no output for next operation
  end
end
