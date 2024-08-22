# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

#ecto://postgres:postgres@db:5432/goodreads_dev
config :goodreads,
  ecto_repos: [Goodreads.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :goodreads, GoodreadsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GoodreadsWeb.ErrorHTML, json: GoodreadsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Goodreads.PubSub,
  live_view: [signing_salt: "M8D6Bmm5"]


  config :goodreads, Goodreads.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "ecto://postgres:1234@db/goodreads_dev",
  pool_size: 10

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :goodreads, Goodreads.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  goodreads: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.4.3",
  goodreads: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
