defmodule Triceratops do


  def exec do
    project = [
      ["file_watcher", "test/files/"],
      ["file_filter", ["file", ""]],
      ["file_copy", "test/files2"],
      ["image_flip", "horizontal"],
      ["image_rotate", 90],
      ["file_move", "test/files3"],
      ["image_optimize", 7],
      ["notification", ["Triceratops", "Done!"]]
    ]
    Triceratops.Runner.run project
  end
end
