defmodule ModuleWebmasterTest do
  use ExUnit.Case
  import Triceratops.Modules.Webmaster

  @screens "test/screens"

  setup_all do
    File.rm_rf @screens
    File.mkdir @screens
    on_exit fn -> File.rm_rf @screens end
    :ok
  end

  test "website ping domain" do
    assert is_float(ping_net "google.com")
    result = ping_net ["facebook.com", "twitter.com", "github.com", "linkedin.com"]
    assert is_list(result)
    assert is_float(hd(result))
  end

  test "website rasterize page" do
    screen = rasterize_page "google.com", @screens
    assert File.regular?(screen)

    screen = rasterize_page "google.com", @screens, %{size: :tablet}
    assert File.regular?(screen)

    screen = rasterize_page "google.com", @screens, %{size: :phone}
    assert File.regular?(screen)

    result = rasterize_page ["facebook.com", "twitter.com", "github.com", "linkedin.com"],
      @screens, %{size: :tablet}
    assert is_list(result)
    assert is_binary(hd(result))
  end
end
