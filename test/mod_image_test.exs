defmodule ModuleImageTest do
  use ExUnit.Case
  import Triceratops.Modules.Image

  @cats "test/cats"

  setup_all do
    File.rm_rf @cats
    File.mkdir @cats
    on_exit fn -> File.rm_rf @cats end
    :ok
  end

  @spec random_cat(atom, charlist) :: atom
  def random_cat(type, path) do
    {:ok, cat_api} = HTTPoison.get "http://thecatapi.com/api/images/get?format=src&type=#{type}"
    {"Location", url} = hd Enum.filter(cat_api.headers, &(elem(&1, 0) == "Location"))
    {:ok, %{body: cat_img}} = HTTPoison.get url
    File.write! path, cat_img
    :ok
  end

  test "optimize JPG image" do
    path = "#{@cats}/nice_cat.jpg"
    random_cat :jpg, path
    assert File.regular? path
    orig_size = File.stat!(path).size
    image_optimize path, :max
    optim_size = File.stat!(path).size
    IO.puts "Image #{path}, original size=#{orig_size}, optimized size=#{optim_size}."
    assert orig_size > optim_size
  end

  test "optimize PNG image" do
    path = "#{@cats}/nice_cat.png"
    random_cat :png, path
    assert File.regular? path
    orig_size = File.stat!(path).size
    image_optimize path, :max
    optim_size = File.stat!(path).size
    IO.puts "Image #{path}, original size=#{orig_size}, optimized size=#{optim_size}."
    assert orig_size > optim_size
  end
end
