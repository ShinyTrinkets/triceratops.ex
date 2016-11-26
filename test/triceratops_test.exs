defmodule TriceratopsTest do
  use ExUnit.Case
  doctest Triceratops

  test "filter module" do
    import Triceratops.Modules.Filters
    files = ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git", "/whatever"]
    assert file_filter(files, {:any, ""}) == ["/usr/local", "/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:file, ""}) == ["/usr/local/bin/gm", "/usr/local/bin/git"]
    assert file_filter(files, {:folder, ""}) == ["/usr/local"]
  end

  test "website ping domain" do
    import Triceratops.Modules.Website
    assert is_float(ping_net "google.com")
    result = ping_net ["facebook.com", "twitter.com", "github.com"]
    assert is_list(result)
    assert is_float(hd(result))
  end

  test "website rasterize page" do
    import Triceratops.Modules.Website
    output = "test/google.desktop.png"
    rasterize_page "google.com", output
    assert File.regular?(output)

    output = "test/google.tablet.png"
    rasterize_page "google.com", output, %{size: :tablet}
    assert File.regular?(output)

    output = "test/google.phone.png"
    rasterize_page "google.com", output, %{size: :phone}
    assert File.regular?(output)
  end
end
