
use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic

# In your config/config.exs file
config :triceratops, Triceratops.Modules.Mail,
  adapter: Bamboo.SMTPAdapter,
  server: "mail.t2sbeta.com",
  port: 25,
  username: "info@t2sbeta.com",
  password: "QWEasd1@3",
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

config :triceratops, Triceratops.Modules.FtpFs,
  host: 'whbeta.com',
  username: 'whbeta',
  password: '${o{bgBO.?(I'
