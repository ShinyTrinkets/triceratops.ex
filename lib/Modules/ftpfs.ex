defmodule Triceratops.Modules.FtpFs do

  def ftp_connect do
    config = Application.get_env(:triceratops, __MODULE__)
    :inets.start
    {:ok, pid} = :inets.start(:ftpc, host: config[:host])
    # Login host with username and password
    :ok = :ftp.user(pid, config[:username], config[:password])
    IO.puts ~s(Connected to FTP at "#{config[:host]}".)
    pid
  end

  def ftp_close(pid) do
    # Kill the connection to host
    :inets.stop(:ftpc, pid)
    IO.puts ~s(Closed FTP connection.)
    nil
  end

  @doc """
  Manually trigger a list of files from remote FTP
  """
  def file_list(folder) do
    pid = ftp_connect
    # List remote files and folders
    {:ok, files} = :ftp.ls pid, :binary.bin_to_list(folder)
    ftp_close pid # kill the connection to host
    files # return the output for next operation
  end

  @doc """
  Upload local file into remote FTP folder
  """
  def ftp_upload(local_file, remote_folder) do
    pid = ftp_connect
    stt = File.stat! local_file
    IO.puts ~s(Local file size=#{stt.size} bits.)
    remote_file = remote_folder <> "/" <> Path.basename(local_file)
    # Push local file into remote directory
    :ok = :ftp.send pid, :binary.bin_to_list(local_file), :binary.bin_to_list(remote_file)
    ftp_close pid # kill the connection to host
    remote_file # return the output for next operation
  end

  @doc """
  Download remote FTP file into local folder
  """
  def ftp_download(remote_file, local_folder) do
    pid = ftp_connect
    local_file = local_folder <> "/" <> Path.basename(remote_file)
    # Receive remote file into the local directory
    :ok = :ftp.recv pid, :binary.bin_to_list(remote_file), :binary.bin_to_list(local_file)
    ftp_close pid # kill the connection to host
    local_file # return the output for next operation
  end
end
