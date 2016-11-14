defmodule Triceratops do
  import Triceratops.Modules.Triggers
  import Triceratops.Modules.Alerts
  import Triceratops.Modules.Filters
  import Triceratops.Modules.LocalFs
  import Triceratops.Modules.Images

  def exec() do
    file_watcher("test/files/", fn(path) ->
      path
        |> file_filter({:file, "jpg$"})
        |> file_copy("test/files2")
        |> image_convert(:jpg)
        |> image_flip(:vertical)
        |> file_move("test/files3")
        |> image_resize({:z, 250})
        |> notification({"Triceratops", "Done!"})
      end)
  end
end
