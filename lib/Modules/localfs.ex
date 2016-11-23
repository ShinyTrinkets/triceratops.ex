defmodule Triceratops.Modules.LocalFs do

  @moduledoc "Module for dealing with local files and folders."

  require Logger
  alias Triceratops.Servers.LocalWatcher

  @doc ~s(TRIGGER: Start events when new files are created inside a folder.)
  @spec trigger_file_watcher(atom, charlist, reference) :: any
  def trigger_file_watcher(name, folder, callback) do
    {:ok, _} = LocalWatcher.start_link name: name, folder: folder,
      callback: fn(path) ->
        LocalWatcher.set_state(name, :running)
        callback.(path)
        LocalWatcher.set_state(name, :pending)
      end
  end

  @doc ~s(Manually trigger a list of local files.)
  @spec file_list(charlist, reference) :: any
  def file_list(folder, callback), do: callback.(ls_r(Path.expand(folder)))

  @doc ~s(Recursively list files.)
  @spec ls_r(charlist) :: list(charlist)
  def ls_r(path \\ ".") do
    cond do
      File.regular?(path) -> [path]
      File.dir?(path) ->
        path
        |> File.ls!
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat
      true -> []
    end
  end


  @spec fix_output(charlist, charlist) :: charlist
  defp fix_output(input, output) do
    # This is just a helper function
    if File.dir?(output), do: output <> "/" <> Path.basename(input), else: output
  end


  @spec file_copy(list(charlist), charlist) :: list(charlist)
  def file_copy(input, output) when is_list(input) do
    Logger.info ~s(Copying #{length(input)} files...)
    Enum.map(input, fn(f) -> file_copy(f, output) end)
  end

  @spec file_copy(charlist, charlist) :: charlist
  def file_copy(input, output) when is_binary(input) do
    output = fix_output(input, output)
    # Copies the contents in source to destination preserving its mode
    :ok = File.cp!(input, output)
    Logger.info ~s(Copied file "#{input}" into "#{output}".)
    output # return the output for next operation
  end


  @spec file_move(list(charlist), charlist) :: list(charlist)
  def file_move(input, output) when is_list(input) do
    Logger.info ~s(Moving #{length(input)} files...)
    Enum.map(input, fn(f) -> file_move(f, output) end)
  end

  @spec file_move(charlist, charlist) :: charlist
  def file_move(input, output) when is_binary(input) do
    output = fix_output(input, output)
    # Renames the source file to destination file
    :ok = File.rename(input, output)
    Logger.info ~s(Moved file "#{input}" in "#{output}".)
    output # return the output for next operation
  end


  @spec file_delete(list(charlist), any) :: list
  def file_delete(input, _) when is_list(input) do
    Logger.info ~s(Deleting #{length(input)} files...)
    Enum.map(input, fn(f) -> file_delete(f) end)
  end

  @spec file_delete(charlist, any) :: none
  def file_delete(input, _) when is_binary(input) do
    # Tries to delete the file path
    :ok = File.rm!(input)
    Logger.info ~s(Deleted file "#{input}".)
    nil # no output for next operation
  end

  @spec file_delete(charlist) :: none
  def file_delete(input), do: file_delete(input, nil)

end


defmodule Triceratops.Servers.LocalWatcher do

  @moduledoc "Module implementing a local folder watcher."

  use GenServer
  require Logger

  ### Client API / Helper methods ###

  @doc ~s(Watch a specified directory.)
  def start_link(args, options \\ []) do
    {name, args} = Keyword.pop(args, :name)
    GenServer.start_link(__MODULE__, args, [name: name] ++ options)
  end

  def get_state(pid) do
    GenServer.call(pid, :state)
  end

  def set_state(pid, state) do
    GenServer.call(pid, {:state, state})
  end

  ### GenServer callbacks ###

  def init(args) do
    folder = args |> Keyword.get(:folder) |> Path.expand
    callback = Keyword.get(args, :callback) # fn (_) -> IO.puts "Changes!" end
    config = %{folder: folder, callback: callback}
    {:ok, _pid} = :fs.start_link(:fs_watcher, folder)
    :fs.subscribe(:fs_watcher)
    Logger.info ~s(Started watching "#{folder}" folder for changes.)
    {:ok, {:pending, config}}
  end

  def handle_call(:state, _from, {state, config}),
    do: {:reply, state, {state, config}}

  def handle_call({:state, state}, _from, {_old_state, config}),
    do: {:reply, state, {state, config}}

  def handle_info({_pid, {:fs, :file_event}, {path, events}}, {state, config}) do
    Logger.info ~s(Projects folder changed: #{path} :: #{inspect events})
    if :modified in events do
      spawn fn -> config.callback.(path) end
    end
    {:noreply, {state, config}}
  end
end
