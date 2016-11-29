defmodule ModuleFilterTest do
  use ExUnit.Case

  test "filter module" do
    import Triceratops.Modules.Filters
    files = ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git", "/whatever"]
    assert file_filter(files, {:any, ""}) == ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:file, ""}) == ["/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:folder, ""}) == ["/usr/local"]
  end
end
