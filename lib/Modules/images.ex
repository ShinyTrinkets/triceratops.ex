defmodule Triceratops.Modules.Images do

  @moduledoc """
  Module for dealing with images.
  This requires that "optipng" and "jpegoptim" are already installed.
  """

  require Logger
  alias Porcelain.Result

  @doc """
  Convert an image from a format, into another format.
  """
  @spec image_convert(any, charlist) :: any
  def image_convert(input, format) when is_binary(format),
    do: image_convert(input, String.to_atom(format))

  @spec image_convert(list(charlist), atom) :: list(charlist)
  def image_convert(input, format) when is_list(input) do
    Logger.info ~s(Converting #{length(input)} images...)
    Enum.map(input, fn(f) -> image_convert(f, format) end)
  end

  @spec image_convert(charlist, atom) :: charlist
  def image_convert(input, format) when is_binary(input) and
      format in [:jpeg, :tiff, :png, :gif, :jp2, :pict, :bmp, :qtif, :psd, :sgi, :tga] do
    output = Path.rootname(input) <> "." <> if format == :jpeg, do: "jpg", else: to_string(format)
    command = ~s(sips -s format #{format} "#{input}" --out "#{output}")
    # Execute sips convert
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips convert!"
    Logger.info ~s(Converted image "#{input}" to "#{format}".)
    output # return the output for next operation
  end


  @spec image_resize(any, {charlist, integer}) :: any
  def image_resize(input, {type, size}) when is_binary(type),
    do: image_resize(input, {String.to_atom(type), size})

  @spec image_resize(list(charlist), {atom, integer}) :: list(charlist)
  def image_resize(input, {type, size}) when is_list(input) do
    Logger.info ~s(Resizing #{length(input)} images...)
    Enum.map(input, fn(f) -> image_resize(f, {type, size}) end)
  end

  @spec image_resize(charlist, {atom, integer}) :: charlist
  def image_resize(input, {type, size}) when is_binary(input) and type in [:w, :h, :z] do
    command = case type do
      :w -> ~s(sips --resampleWidth #{size} "#{input}")
      :h -> ~s(sips --resampleHeight #{size} "#{input}")
      :z  -> ~s(sips -Z #{size} "#{input}")
    end
    # Execute sips resize
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips resize!"
    Logger.info ~s(Resized image "#{input}" #{type} to #{size} px.)
    input # return the output for next operation
  end


  @spec image_flip(any, charlist) :: any
  def image_flip(input, orientation) when is_binary(orientation),
    do: image_flip(input, String.to_atom(orientation))

  @spec image_flip(list(charlist), atom) :: list(charlist)
  def image_flip(input, orientation) when is_list(input) do
    Logger.info ~s(Flipping #{length(input)} images...)
    Enum.map(input, fn(f) -> image_flip(f, orientation) end)
  end

  @spec image_flip(charlist, atom) :: charlist
  def image_flip(input, orientation) when is_binary(input) and orientation in [:vertical, :horizontal] do
    command = ~s(sips -f #{orientation} "#{input}")
    # Execute sips flip
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips flip!"
    Logger.info ~s(Flipped image "#{input}" to #{orientation}.)
    input # return the output for next operation
  end


  @spec image_rotate(list(charlist), integer) :: list(charlist)
  def image_rotate(input, angle) when is_list(input) do
    Logger.info ~s(Rotating #{length(input)} images...)
    Enum.map(input, fn(f) -> image_rotate(f, angle) end)
  end

  @spec image_rotate(charlist, integer) :: charlist
  def image_rotate(input, angle) when is_binary(input) and angle > 0 and angle < 360 do
    command = ~s(sips -r #{angle} "#{input}")
    # Execute sips rotate
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips rotate!"
    Logger.info ~s(Rotated image "#{input}" to #{angle} deg.)
    input # return the output for next operation
  end

  @doc """
  Optimize PNG and JPG images;
  Requires: optipng and jpegoptim;
  """
  @spec image_optimize(any, charlist) :: any
  def image_optimize(input, level) when is_binary(level),
    do: image_optimize(input, String.to_atom(level))

  @spec image_optimize(list(charlist), atom) :: list(charlist)
  def image_optimize(input, level) when is_list(input) do
    Logger.info ~s(Optimizing #{length(input)} images...)
    Enum.map(input, fn(f) -> image_optimize(f, level) end)
  end

  @spec image_optimize(charlist, atom) :: charlist
  def image_optimize(input, level) when is_binary(input) and is_atom(level) do
    ext = Path.extname(input)
    command = cond do
      ext in [".png", ".bmp", ".gif", ".tiff"] -> optipng(input, level)
      ext in [".jpg", ".jpeg"] -> jpegopt(input, level)
      true -> ""
    end
    # Execute optimize
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot optimize image!"
    Logger.info ~s(Optimized image "#{input}" level "#{level}".)
    input # return the output for next operation
  end

  defp optipng(input, level) do
    level = case level do
      :min -> ""
      :max -> "-o7"
        _  -> "-o5"
    end
    ~s(optipng -strip all #{level} "#{input}")
  end
  defp jpegopt(input, level) do
    level = case level do
      :min -> ""
      :max -> "-m70"
        _  -> "-m80"
    end
    ~s(jpegoptim --strip-all #{level} "#{input}")
  end
end
