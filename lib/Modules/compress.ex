defmodule Triceratops.Modules.Compress do

  @moduledoc "Module for dealing with archives (Zip, 7zip, Tar.gz, Tar.bz)."

  require Logger
  alias FileSmasher.Tar
  alias FileSmasher.SevenZip

  @doc """
  Compress 1 or more files, inside an archive.
  The files are appended in the archive until it is deleted.
  """
  @spec compress(any, charlist, tuple) :: any
  def compress(input, output, method) when is_list(method),
    do: compress(input, output, List.to_tuple(method))

  @spec compress(list(charlist), charlist, tuple) :: list(charlist)
  def compress(input, output, method) when is_list(input) do
    Logger.info ~s(Compressing #{length(input)} files...)
    Enum.map(input, fn(f) -> compress(f, output, method) end)
  end

  @spec compress(charlist, charlist, tuple) :: charlist
  def compress(input, output, method) when is_binary(input) and is_tuple(method) do
    :ok = cond do
      elem(method, 0) in [:gz, :bz, :xz] -> Tar.compress output, input, method
      elem(method, 0) in [:'7z', :zip] -> SevenZip.compress output, input, method
    end
    Logger.info ~s(Compressed "#{input}" using #{inspect method}.)
    output # return the output for next operation
  end


  @spec extract(list(charlist), charlist, boolean) :: list(charlist)
  def extract(input, output, overwrite) when is_list(input) do
    Logger.info ~s(Extracting #{length(input)} archives...)
    Enum.map(input, fn(f) -> extract(f, output, overwrite) end)
  end

  @spec extract(charlist, charlist, boolean) :: charlist
  def extract(input, output, overwrite) when is_binary(input) and is_boolean(overwrite) do
    :ok = SevenZip.extract input, output, overwrite
    Logger.info ~s(Extrated "#{input}" overwrite=#{overwrite}.)
    output # return the output for next operation
  end

end
