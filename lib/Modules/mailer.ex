defmodule Triceratops.Modules.Mail do

  @moduledoc "Module for dealing with e-mails."

  use Bamboo.Mailer, otp_app: :triceratops
  import Bamboo.Email

  def send_mail(input, to) do
    config = Application.get_env(:triceratops, __MODULE__)
    message = "<b>Files:</b> " <> to_string(input)
    mail = new_email(
      to: to,
      from: config.username,
      subject: "Triceratops notification",
      html_body: message
    )
    deliver_now mail
  end
end
