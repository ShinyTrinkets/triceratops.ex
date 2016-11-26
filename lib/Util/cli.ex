defmodule Triceratops.Util.CLI do

  @moduledoc "The escript built application."

  require Logger

  defp forever_sleep do
    Process.sleep(250)
    forever_sleep
  end

  def main(args \\ []) do
    {opts, _, _} = OptionParser.parse(args, aliases: [h: :help])
    if opts == [help: true] do
      {_, _, version} = List.first :application.which_applications
      IO.puts """
      \nTriceratops version: #{version};
      """
    else
      Logger.info "Warming up..."
      Triceratops.Application.start
      Process.sleep(250)
      Triceratops.Project.Runner.initial_launch
      forever_sleep
      Logger.info "Shutting down..."
    end
  end
end
