
use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic

# In your config/config.exs file
config :triceratops, Triceratops.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "mail.t2sbeta.com",
  port: 25,
  username: "info@t2sbeta.com",
  password: "QWEasd1@3",
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1
