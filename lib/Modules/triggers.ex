defmodule Triceratops.Modules.Triggers do
  require Logger

  @doc """
  Start events when time runs out and repeat (once, or multiple times)
  """
  def timer({:once, time}, callback) do
    Process.sleep(time * 1000)
    callback.("")
  end
  def timer({:many, interval, :infinity}, callback) do
    # Interval in seconds, repeat forever
    Ticker.start_tick self, interval
    run_timer callback
  end
  def timer({:many, interval, repeat_nr}, callback) do
    # Interval in seconds, repeat number of times
    Ticker.start_tick self, interval, (interval * (repeat_nr-1) * 1000)
    run_timer callback
  end

  defp run_timer(callback) do
    receive do
      {:tick, _index} = message ->
        IO.inspect(message)
        callback.("")
        run_timer(callback)
      {:last_tick, _index} = message ->
        IO.inspect(message)
        callback.("")
        :done
    end
  end


  @doc """
  Start events when new files are created inside a folder
  """
  def file_watcher(folder, callback) do
    # Watch a directory and registers a callback
    Fwatch.watch_dir(folder, fn(path, events) ->
      Logger.info ~s(File #{path} changed: #{inspect events})
      if :created in events && :modified in events do
        callback.(path)
      end
    end)
  end
end

defmodule Ticker do
  require Logger

  def start_tick(recipient_pid, tick_interval, duration \\ :infinity) do
    # Start a process whose only responsibility is to wait for the interval
    ticker_pid = spawn(__MODULE__, :loop_timer, [recipient_pid, tick_interval * 1000, 1])
    # And send a tick to the recipient pid and loop back
    send(ticker_pid, :send_tick)
    schedule_terminate(ticker_pid, duration)
    # Return the pid of the ticker, which can be used to stop the ticker
    ticker_pid
  end

  def stop_tick(ticker_pid) do
    send(ticker_pid, :terminate)
  end

  def loop_timer(recipient_pid, tick_interval, current_index) do
    # Internal api
    receive do
      :send_tick ->
        send(recipient_pid, {:tick, current_index}) # send the tick event
        Process.send_after(self, :send_tick, tick_interval) # schedule a self event after interval
        loop_timer(recipient_pid, tick_interval, current_index + 1)
      :terminate ->
        :ok # terminating
        # NOTE: we could also optionally wire it up to send a last_tick event when it terminates
        send(recipient_pid, {:last_tick, current_index})
      oops ->
        Logger.info "Received unexpected message: #{inspect oops}"
        loop_timer(recipient_pid, tick_interval, current_index + 1)
    end
  end

  defp schedule_terminate(_pid, :infinity),
    do: :ok
  defp schedule_terminate(ticker_pid, duration),
    do: Process.send_after(ticker_pid, :terminate, duration)
end
