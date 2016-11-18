defmodule Triceratops do
  require Logger
  alias Poison.Parser
  alias Triceratops.Project
  @on_load :on_load

  def on_load do
    log = Application.get_env(:logger, :info)[:path]
    if File.regular?(log), do: File.rm(log)
    :ok
  end

  def main(_) do
    Logger.info "Warming up..."
    # Fwatch.watch_dir("./projects/", fn(proj, events) ->
    #   Logger.info ~s(Projects folder changed: #{inspect events})
    #   if :created in events && :modified in events do
    #     Logger.info ~s(New project: #{proj}.)
    #   end
    # end)
    p = Parser.parse! File.read! "./project.json"
    Logger.info "Running project..."
    Project.run p
    Logger.info "Shutting down..."
  end
end
