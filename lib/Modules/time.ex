defmodule Triceratops.Modules.Time do

  @moduledoc "Module for triggers: time and file watcher."

  require Logger
  alias Triceratops.Servers.Timer

  @doc "Continue after delay."
  @spec time_delay(integer | float, reference) :: any
  def time_delay(time, callback) do
    Process.sleep(round(time * 1000))
    callback.("")
  end

  @doc "TRIGGER: Repeat events forever."
  @spec trigger_repeat(integer | float, reference) :: any
  def trigger_repeat(interval, callback) do
    Logger.info ~s(Periodic repeat every #{interval} seconds.)
    Timer.start_link interval: round(interval * 1000), callback: callback
  end
end


defmodule Triceratops.Servers.Timer do

  @moduledoc "Module implementing a timer."

  use GenServer

  ### Client API / Helper methods ###

  def start_link(args, options \\ []) do
    GenServer.start_link(__MODULE__, args, options)
  end

  def stop(server) do
    GenServer.stop(server)
  end

  def get_config(server) do
    GenServer.call(server, :get)
  end

  ### GenServer API ###

  def init(args) do
    callback = Keyword.get(args, :callback)
    interval = Keyword.get(args, :interval)
    config = %{callback: callback, interval: interval}
    IO.puts "Starting timer: #{inspect config}"
    timer = Process.send_after(self, :work, interval)
    {:ok, {config, timer}}
  end

  def handle_call(:get, _from, state) do
    {config, timer} = state
    next_tick = Process.read_timer(timer)
    IO.puts "Get timer: #{inspect config}"
    {:reply, {config, next_tick}, state}
  end

  def handle_info(:work, {state, _old_timer}) do
    spawn fn -> state.callback.("") end
    timer = Process.send_after(self, :work, state.interval)
    {:noreply, {state, timer}}
  end
end
