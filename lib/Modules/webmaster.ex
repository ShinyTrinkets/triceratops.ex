defmodule Triceratops.Modules.Webmaster do

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


  @doc "Helper method to convert HTTP addresses into file names."
  def sluggify_address(addr), do: Regex.replace(~r/[^a-z0-9]/, addr, "_")


  def rasterize_page(input, output, options \\ %{})

  @spec rasterize_page(list(charlist), charlist, map) :: list(charlist)
  def rasterize_page(input, output, options) when is_list(input) do
    Logger.info ~s(Rasterizing #{length(input)} pages...)
    Enum.map(input, fn(f) -> rasterize_page(f, output, options) end)
  end

  @doc """
  Makes a print screen of the page and saves the PNG file in the output folder.
  """
  @spec rasterize_page(charlist, charlist, map) :: charlist
  def rasterize_page(address, output, options) do
    options = rasterize_options address, output, options
    js_path = rasterize_page_js options
    # Execute JS code
    %Result{status: status} = Porcelain.shell("phantomjs #{js_path}")
    File.rm js_path
    if status != 0, do: raise "Cannot rasterize page!"
    options.output # output for the next operation
  end

  defp rasterize_options(address, output, options) do
    slug = sluggify_address(address
      |> String.replace_leading("http://", "")
      |> String.replace_leading("https://", "")
      |> String.replace_trailing("/", "")
    )
    address = if String.starts_with?(address, "http"), do: address, else: "http://#{address}"
    size = Map.get options, :size, :desktop
    zoom = Map.get options, :zoom, 1
    output = "#{output}/#{slug}.#{size}.png"
    %{address: address, output: output, size: size, zoom: zoom}
  end

  defp rasterize_page_js(options) do
    {:ok, tmp_path} = Temp.mkdir %{prefix: "triceratops"}
    js_path = "#{tmp_path}/rasterize_page.js"
    File.write! js_path, rasterize_page_code(options)
    js_path
  end

  defp rasterize_page_code(%{address: address, output: output, size: size, zoom: zoom}) do
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
    var page = require('webpage').create()
    page.settings.userAgent = "#{agent}"
    page.viewportSize = {width: #{width}, height: #{height}}
    page.zoomFactor = #{zoom}
    page.open("#{address}", function (status) {
      if (status !== 'success') {
        console.log('Unable to load the address "#{address}"!')
        phantom.exit(1)
      } else {
        console.log('Rendering "#{address}"...')
        window.setTimeout(function () {
          page.render("#{output}")
          phantom.exit()
        }, 250)
      }
    })
    """
  end


  @spec netstat_page(list(charlist), charlist) :: list(charlist)
  def netstat_page(input, output) when is_list(input) do
    Logger.info ~s(Net-stat #{length(input)} pages...)
    Enum.map(input, fn(f) -> netstat_page(f, output) end)
  end

  @doc """
  Calculates web-page statistics and saves the result in the output folder.
  """
  @spec netstat_page(charlist, charlist) :: charlist
  def netstat_page(address, output) do
    js_path = netstat_page_js(address)
    # Execute JS code
    %Result{out: stdout, status: status} = Porcelain.shell("phantomjs #{js_path}")
    File.rm js_path
    if status != 0, do: raise "Cannot net-stat page!"
    netstat_analyze stdout
    # Convert address into a file string
    slug = sluggify_address(
      address
        |> String.replace_leading("http://", "")
        |> String.replace_leading("https://", "")
    )
    output = "#{output}/#{slug}.json"
    File.write! output, stdout
    output # output for the next operation
  end

  defp netstat_page_js(address) do
    {:ok, tmp_path} = Temp.mkdir %{prefix: "triceratops"}
    js_path = "#{tmp_path}/netstat_page.js"
    File.write! js_path, netstat_page_code(address)
    js_path
  end

  defp netstat_page_code(address) do
    address = if String.starts_with?(address, "http"), do: address, else: "http://#{address}"
    """
    var page = require('webpage').create()
    var startTime = new Date()
    var statistics = {}
    var sorted = []
    page.onResourceRequested = function(req) {
      if (req.time) req.time = new Date(req.time)
      statistics[req.id] = { request: req, startReply: null, endReply: null }
      delete req.headers
      delete req.id
    }
    page.onResourceReceived = function(res) {
      self = statistics[res.id]
      if (res.time) res.time = new Date(res.time)
      if (res.stage === 'start') self.startReply = res
      if (res.stage === 'end') {
        self.endReply = res
        sorted.push({
          method: self.request.method,
          url: self.request.url,
          receive_time: self.endReply.time - self.startReply.time,
          wait_time: self.startReply.time - self.request.time,
          total_time: self.endReply.time - self.request.time,
          body_size: self.startReply.bodySize,
          content_type: self.endReply.contentType.split(";")[0],
          final_status: self.endReply.statusText
        })
      }
    }
    page.open("#{address}", function(status) {
      if (status !== 'success') {
        console.log('Unable to load the address "#{address}"!')
        phantom.exit(1)
      } else {
        var endTime = new Date()
        var data = {
          url: "#{address}",
          title: page.evaluate(function() { return document.title }),
          loading_time: (endTime - startTime),
          start_time: startTime,
          end_time: endTime,
          statistics: sorted
        }
        console.log(JSON.stringify(data, undefined, 2))
        phantom.exit()
      }
    })
    """
  end

  def netstat_analyze(stdout) do
    alias Poison.Parser
    data = Parser.parse!(stdout)
    stats = data["statistics"]
    IO.puts ~s(Requests : #{length stats})

    speed_stats = stats
      |> Enum.filter( &(!String.starts_with?(&1["url"], "data:")) )
      |> Enum.map( &({ &1["receive_time"], &1["url"] }) )
    fastest = speed_stats
      |> Enum.sort( &(elem(&1, 0) < elem(&2, 0)) )
      |> Enum.take(5)
    slowest = speed_stats
      |> Enum.sort( &(elem(&1, 0) > elem(&2, 0)) )
      |> Enum.take(5)

    size_stats = stats
      |> Enum.map( &({ &1["body_size"], &1["url"] }) )
    smallest = size_stats
      |> Enum.sort( &(elem(&1, 0) < elem(&2, 0)) )
      |> Enum.take(5)
    largest = size_stats
      |> Enum.sort( &(elem(&1, 0) > elem(&2, 0)) )
      |> Enum.take(5)

    IO.puts ~s(\nFastest : #{inspect fastest})
    IO.puts ~s(\nSlowest : #{inspect slowest})

    IO.puts ~s(\nSmallest : #{inspect smallest})
    IO.puts ~s(\nLargest : #{inspect largest})
  end

end
