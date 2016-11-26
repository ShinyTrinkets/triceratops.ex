defmodule Triceratops.Modules.Website do

  @moduledoc "Module for dealing with websites and pages."

  require Logger
  alias Porcelain.Result

  def ping_host(_, host) do
    command = ~s(ping -c 5 -s 120 #{host})
    # Execute sips convert
    %Result{status: status, out: out} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot send ping!"
    match = Regex.named_captures ~r"round-trip \S+ = \d+\.\d+/(?<avg>\d+\.\d+)/\d+\.\d+/", out
    String.to_float(match["avg"]) # output for the next operation
  end

end
