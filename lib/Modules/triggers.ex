defmodule Triceratops.Modules.Triggers do

  # Timed start (once/ repeated)
  # Watch local files, remote FTP, SFTP, SSH files
  # Load a file list from HDD
  # Ping a list of websites
  # Wait for a specific e-mail
  # Wait for a specific tweet

  @doc """
  Manually trigger a list of files
  """
  def file_list(folder, callback) do
    files = ls_r(folder)
    callback.(files)
  end

  @doc """
  Recursively list files
  """
  @spec ls_r(charlist) :: list(charlist)
  def ls_r(path \\ ".") do
    cond do
      File.regular?(path) -> [path]
      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat
      true -> []
    end
  end

  @doc """
  Watch for new files inside a folder
  """
  def file_watcher(folder, callback) do
    # Watch a directory and registers a callback
    Fwatch.watch_dir(folder, fn(path, events) ->
      IO.puts "File #{path} changed"
      IO.inspect events
      if :created in events && :modified in events do
        callback.(path)
      end
    end)
  end
end
