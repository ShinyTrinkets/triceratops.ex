defmodule ModuleImageTest do
  use ExUnit.Case
  import Triceratops.Modules.Images

  @cats "test/cats"

  setup_all do
    File.mkdir! @cats
    on_exit fn -> File.rm_rf @cats end
    :ok
  end

  def random_cat(path) do
    {:ok, cat_api} = HTTPoison.get "http://thecatapi.com/api/images/get?format=src&type=jpg"
    {"Location", url} = hd Enum.filter(cat_api.headers, &(elem(&1, 0) == "Location"))
    {:ok, %{body: cat_img}} = HTTPoison.get url
    File.write! path, cat_img
  end

  test "optimize JPG image" do
    jpg = "#{@cats}/cat1.jpg"
    random_cat jpg
    assert File.regular? jpg
    orig_size = File.stat!(jpg).size
    image_optimize jpg, :max
    optim_size = File.stat!(jpg).size
    IO.puts "Image #{jpg}, original size=#{orig_size}, optimized size=#{optim_size}."
    assert orig_size > optim_size
  end
end
