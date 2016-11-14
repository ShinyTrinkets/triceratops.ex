defmodule TriceratopsTest do
  use ExUnit.Case
  doctest Triceratops
  import Triceratops.Modules.Filters

  test "filter module" do
    files = ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git", "/whatever"]
    assert file_filter(files, {:any, ""}) == ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:file, ""}) == ["/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:folder, ""}) == ["/usr/local"]
  end
end
