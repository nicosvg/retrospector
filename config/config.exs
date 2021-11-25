# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
#use Mix.Config
import Config

config :retrospector,
       ecto_repos: [Retrospector.Repo]

# Configures the endpoint
config :retrospector,
       RetrospectorWeb.Endpoint,
       url: [
         host: "localhost"
       ],
       secret_key_base: "aYBhxBZe1c+SGtv6okISeSdwUMP98p8Liyu/aar5tATXVzx3ywCi5+Z4eVm7L2+Z",
       render_errors: [
         view: RetrospectorWeb.ErrorView,
         accepts: ~w(html json),
         layout: false
       ],
       pubsub_server: Retrospector.PubSub,
       live_view: [
         signing_salt: "5Nx7oxJc"
       ]

# Configures Elixir's Logger
config :logger,
       :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
       version: "0.12.18",
       default: [
         args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
         cd: Path.expand("../assets", __DIR__),
         env: %{
           "NODE_PATH" => Path.expand("../deps", __DIR__)
         }
       ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#import_config "#{Mix.env()}.exs"
import_config "#{config_env()}.exs"
