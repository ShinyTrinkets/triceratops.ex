defmodule Triceratops do
  require Logger
  @on_load :on_load

  def on_load do
    log = Application.get_env(:logger, :info)[:path]
    if File.regular?(log), do: File.rm(log)
    :ok
  end

  def start do
    project = [
      ["file_watcher", "test/files/"],
      ["file_filter", ["file", ""]],
      ["file_copy", "test/files2"],
      ["image_flip", "horizontal"],
      ["image_rotate", 90],
      ["image_resize", ["w", 480]],
      ["file_move", "test/files3"],
      ["image_optimize", 7],
      ["notification", ["Triceratops", "Done!"]]
    ]
    Logger.info "Running project!"
    Triceratops.Runner.run project
  end
end
