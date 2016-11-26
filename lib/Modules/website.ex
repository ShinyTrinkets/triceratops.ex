defmodule Triceratops.Modules.Website do

  @moduledoc """
  Module for dealing with websites and pages.
  This requires that "phantomjs" is already installed.
  """

  require Logger
  alias Porcelain.Result

  @doc "Send ICMP ECHO_REQUEST packets to network hosts."
  @spec ping_net(list(charlist)) :: list(float)
  def ping_net(input) when is_list(input) do
    Logger.info ~s(Pinging #{length(input)} hosts...)
    Enum.map(input, fn(f) -> ping_net(f) end)
  end

  @spec ping_net(charlist) :: float
  def ping_net(host) do
    command = ~s(ping -c 5 -s 120 #{host})
    # Execute ping command
    %Result{status: status, out: out} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot send ping!"
    match = Regex.named_captures ~r"round-trip \S+ = \d+\.\d+/(?<avg>\d+\.\d+)/\d+\.\d+/", out
    String.to_float(match["avg"]) # output for the next operation
  end


  def rasterize_page(input, output, options \\ %{})

  @spec rasterize_page(list(charlist), charlist, map) :: list(charlist)
  def rasterize_page(input, output, options) when is_list(input) do
    Logger.info ~s(Rasterizing #{length(input)} pages...)
    Enum.map(input, fn(f) -> rasterize_page(f, output, options) end)
  end

  @spec rasterize_page(charlist, charlist, map) :: charlist
  def rasterize_page(address, output, options) do
    options = Map.merge(options, %{address: address, output: output})
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
