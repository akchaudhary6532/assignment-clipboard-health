import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :clipboard, Clipboard.Repo,
  # username: "postgres",
  # password: "postgres",
  # hostname: "localhost",
  database: "clipboard_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :clipboard, ClipboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ajUlWSOqoJIedGQbZR1A4yXCdz6QryziUB4dKDPBhhNLciaKOFeeg/zeFwRQu62Y",
  server: false

# In test we don't send emails.
config :clipboard, Clipboard.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
