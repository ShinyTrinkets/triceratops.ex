defmodule Triceratops.Modules.Website do

  @moduledoc """
  Module for dealing with websites and pages.
  This requires that "phantomjs" is already installed.
  """

  require Logger
  alias Porcelain.Result

  @spec ping_host(charlist, charlist) :: float
  def ping_host(_, host), do: ping_host(host)

  @spec ping_host(charlist) :: float
  def ping_host(host) do
    command = ~s(ping -c 5 -s 120 #{host})
    # Execute ping command
    %Result{status: status, out: out} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot send ping!"
    match = Regex.named_captures ~r"round-trip \S+ = \d+\.\d+/(?<avg>\d+\.\d+)/\d+\.\d+/", out
    String.to_float(match["avg"]) # output for the next operation
  end


  def rasterize_page(%{output: output} = options) do
    js_path = rasterize_page_js(options)
    # Execute ping command
    %Result{status: status} = Porcelain.shell("phantomjs #{js_path}")
    if status != 0, do: raise "Cannot rasterize page!"
    File.rm js_path
    output # output for the next operation
  end

  def rasterize_page_js(options) do
    {:ok, tmp_path} = Temp.mkdir %{prefix: "triceratops"}
    js_path = "#{tmp_path}/rasterize_page.js"
    code_js = rasterize_page_code options
    File.write! js_path, code_js
    js_path
  end

  def rasterize_page_code(%{address: address, output: output} = options) do
    address = if String.starts_with?(address, "http"), do: address, else: "http://#{address}"
    zoom = Map.get options, :zoom, 1
    size = Map.get options, :size, :desktop
    {width, height} = case size do
      :desktop -> {1366, 768}
      :tablet -> {1024, 768}
      :phone -> {320, 568}
    end
    agent = case size do
      :desktop -> "Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.3 (KHTML, like Gecko) Chrome/55.0 Safari/537.3"
      :tablet -> "Mozilla/5.0 (Linux; U; Android 4.0;) AppleWebKit/537.3 (KHTML, like Gecko) Chrome/55.0 Safari/537.3"
      :phone -> "Mozilla/5.0 (Linux; U; Android 4.0;) AppleWebKit/537.3 (KHTML, like Gecko) Chrome/55.0 Mobile Safari/537.3"
    end
    """
    var page = require('webpage').create();
    page.settings.userAgent = "#{agent}";
    page.viewportSize = {width: #{width}, height: #{height}};
    page.zoomFactor = #{zoom};
    page.open("#{address}", function (status) {
      if (status !== 'success') {
        console.log('Unable to load the address "#{address}"!');
        phantom.exit(1);
      } else {
        console.log('Rendering "#{address}"...');
        window.setTimeout(function () {
          page.render("#{output}");
          phantom.exit();
        }, 250);
      }
    });
    """
  end

end
