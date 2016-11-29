defmodule ModuleWebmasterTest do
  use ExUnit.Case
  import Triceratops.Modules.Webmaster

  @screens "test/screens"

  setup_all do
    File.mkdir! @screens
    on_exit fn -> File.rm_rf @screens end
    :ok
  end

  test "website ping domain" do
    assert is_float(ping_net "google.com")
    result = ping_net ["facebook.com", "twitter.com", "github.com"]
    assert is_list(result)
    assert is_float(hd(result))
  end

  test "website rasterize page" do
    screen = "#{@screens}/google.desktop.png"
    rasterize_page "google.com", screen
    assert File.regular?(screen)

    screen = "#{@screens}/google.tablet.png"
    rasterize_page "google.com", screen, %{size: :tablet}
    assert File.regular?(screen)

    screen = "#{@screens}/google.phone.png"
    rasterize_page "google.com", screen, %{size: :phone}
    assert File.regular?(screen)
  end
end
