defmodule Triceratops.Helpers do
  def fix_output(input, output) do
    case File.dir?(output) do
      true -> output <> "/" <> Path.basename(input)
      false -> output
    end
  end
end
