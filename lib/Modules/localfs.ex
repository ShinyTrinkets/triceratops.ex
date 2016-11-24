defmodule Triceratops.Modules.LocalFs do

  @moduledoc "Module for dealing with local files and folders."

  require Logger
  alias Triceratops.Servers.LocalWatcher

  @doc ~s(TRIGGER: Start events when new files are created inside a folder.)
  @spec trigger_file_watcher(atom, charlist, reference) :: any
  def trigger_file_watcher(name, folder, callback) do
    {:ok, pid} = LocalWatcher.start_link name: name, folder: folder, callback: callback
    pid
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
    GenServer.start_link(__MODULE__, args, [name: args[:name]] ++ options)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  ### GenServer callbacks ###

  def init(args) do
    start_watcher(args)
    {:ok, %{folder: args[:folder], callback: args[:callback]}}
  end

  def handle_info({_pid, {:fswatch, :file_event}, {path, events}}, config) do
    Logger.info ~s(File changed: #{path} :: #{inspect events})
    if :updated in events do
      unless Path.basename(path) |> String.starts_with?(".") do
        spawn fn -> config.callback.(path) end
      end
    end
    {:noreply, config}
  end

  ### Helpers ###

  defp start_watcher(args) do
    name = "#{args[:name]}_watcher" |> String.to_atom
    folder = args[:folder] |> Path.expand
    {:ok, _} = Sentix.start_link name, [folder], [filter: [:created, :updated]]
    Logger.info ~s(Started watching "#{folder}" folder for changes.)
    Sentix.subscribe name
  end
end
