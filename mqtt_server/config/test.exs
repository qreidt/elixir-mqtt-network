import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mqtt_server, MQTTServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "II/Ev0zwbp47/ohGEl6r6UHqRRigN32sGqf9LGjzgchP10lsekX6du1OOJ4qQhPv",
  server: false

# In test we don't send emails.
config :mqtt_server, MQTTServer.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
