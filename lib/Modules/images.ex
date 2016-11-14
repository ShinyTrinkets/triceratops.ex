defmodule Triceratops.Modules.Images do
  alias Porcelain.Result

  # Using Simple Image Conversion from command line
  # IMPORTANT: By using sips, the image files are permanently altered! You cannot reverse the effects!
  # It's important to make copies of the original files if you want to keep them!

  # TODO :: Optimize image, optimize video

  def image_convert(input, format) when is_list(input) do
    IO.puts ~s(Converting #{length(input)} images...)
    Enum.map(input, fn(f) -> image_convert(f, format) end)
  end

  def image_convert(input, format) when is_binary(input) do
    # jpeg, png, gif, tiff, pdf, pict
    format = format |> to_string |> String.downcase
    output = Path.rootname(input) <> "." <> format
    format = if format == "jpg", do: "jpeg", else: format
    command = ~s(sips -s format #{format} "#{input}" --out "#{output}")
    # Execute sips convert
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips convert!"
    IO.puts ~s(Converted image "#{input}" to "#{format}".)
    output # return the output for next operation
  end


  def image_resize(input, {type, size}) when is_list(input) do
    IO.puts ~s(Resizing #{length(input)} images...)
    Enum.map(input, fn(f) -> image_resize(f, {type, size}) end)
  end

  def image_resize(input, {type, size}) when is_binary(input) do
    command = case type do
      :w -> ~s(sips --resampleWidth #{size} "#{input}")
      :h -> ~s(sips --resampleHeight #{size} "#{input}")
      _  -> ~s(sips -Z #{size} "#{input}")
    end
    # Execute sips resize
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips resize!"
    IO.puts ~s(Resized image "#{input}" #{type} to #{size} px.)
    input # return the output for next operation
  end


  def image_flip(input, orientation) when is_list(input) do
    IO.puts ~s(Flipping #{length(input)} images...)
    Enum.map(input, fn(f) -> image_flip(f, orientation) end)
  end

  def image_flip(input, orientation) when is_binary(input) do
    # :vertical | :horizontal
    orientation = if orientation == :vertical, do: "vertical", else: "horizontal"
    command = ~s(sips -f #{orientation} "#{input}")
    # Execute sips flip
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips flip!"
    IO.puts ~s(Flipped image "#{input}" to #{orientation}.)
    input # return the output for next operation
  end


  def image_rotate(input, angle) when is_list(input) do
    IO.puts ~s(Rotating #{length(input)} images...)
    Enum.map(input, fn(f) -> image_rotate(f, angle) end)
  end

  def image_rotate(input, angle) when is_binary(input) do
    command = ~s(sips -r #{angle} "#{input}")
    # Execute sips rotate
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot sips rotate!"
    IO.puts ~s(Rotated image "#{input}" to #{angle} deg.)
    input # return the output for next operation
  end
end
