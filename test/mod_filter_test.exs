defmodule ModuleFilterTest do
  use ExUnit.Case
  import Triceratops.Modules.Filters

  test "filter files vs folders" do
    files = ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git", "/whatever"]
    assert file_filter(files, {:any, ""}) == ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:file, ""}) == ["/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:folder, ""}) == ["/usr/local"]
  end

  test "filter by name" do
    files = ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git", "/whatever"]
    assert file_filter(files, {:any, "local$"}) == ["/usr/local"]
    assert file_filter(files, {:any, "gm"}) == ["/usr/local/bin/gm"]
  end
end
