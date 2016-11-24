defmodule Triceratops.Modules.Time do

  @moduledoc "Module for triggers: time and file watcher."

  require Logger
  alias Triceratops.Servers.Timer

  @doc ~s(TRIGGER: Repeat events forever.)
  @spec trigger_repeat(atom, integer | float, reference) :: any
  def trigger_repeat(name, interval, callback) do
    {:ok, pid} = Timer.start_link name: name, interval: round(interval * 1000), callback: callback
    pid
  end

  @doc ~s(Continue after delay.)
  @spec time_delay(charlist, integer | float) :: charlist
  def time_delay(_input, time) do
    Process.sleep(round(time * 1000))
    ""
  end
end


defmodule Triceratops.Servers.Timer do

  @moduledoc "Module implementing a timer."

  use GenServer
  require Logger

  ### Client API / Helper methods ###

  def start_link(args, options \\ []) do
    {name, args} = Keyword.pop(args, :name)
    GenServer.start_link(__MODULE__, args, [name: name] ++ options)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def get_config(pid) do
    GenServer.call(pid, :get)
  end

  def reset_timer(pid) do
    GenServer.call(pid, :reset)
  end

  ### GenServer API ###

  @doc ~s(The interval is in milisec, the callback must have arity 1.)
  def init(args) do
    interval = Keyword.get(args, :interval)
    callback = Keyword.get(args, :callback) # fn (_) -> IO.puts "Work!" end
    config = %{callback: callback, interval: interval}
    Logger.info ~s(Periodic repeat every #{interval} ms.)
    timer = Process.send_after(self, :work, interval)
    {:ok, {config, timer}}
  end

  def handle_call(:reset, _from, {config, old_timer}) do
    Process.cancel_timer(old_timer)
    timer = Process.send_after(self, :work, config.interval)
    {:reply, :ok, {config, timer}}
  end

  def handle_call(:get, _from, state) do
    {config, timer} = state
    next_tick = Process.read_timer(timer)
    {:reply, {config, next_tick}, state}
  end

  def handle_info(:work, {config, _old_timer}) do
    spawn fn -> config.callback.("") end
    timer = Process.send_after(self, :work, config.interval)
    {:noreply, {config, timer}}
  end
end
