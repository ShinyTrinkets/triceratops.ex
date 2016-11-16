defmodule Triceratops.Functions do
  def all_functions do
    modules = ["Triggers", "Alerts", "Filters", "Images", "LocalFs", "FtpFs"]
    Enum.map(modules, fn(m) ->
      # Pointer to real module
      mod = Module.concat Triceratops.Modules, m
      # All exposed functions from that module
      funcs = mod.module_info(:exports) -- [__info__: 1, module_info: 0, module_info: 1]
      # Map the function, with the module name
      Enum.map funcs, fn({k, _}) -> {k, mod} end
    end)
      |> Enum.flat_map(&(&1))
      |> Enum.into(%{})
  end
end
