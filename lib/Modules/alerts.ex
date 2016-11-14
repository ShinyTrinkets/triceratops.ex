defmodule Triceratops.Modules.Alerts do
  alias Porcelain.Result

  def notification(_input, {title, message}) do
    command = ~s(osascript -e 'display notification "#{message}" sound name "Pop" with title "#{title}"')
    # Execute sips convert
    %Result{status: status} = Porcelain.shell(command)
    if status != 0, do: raise "Cannot launch notification!"
    nil # no output for next operation
  end
end
