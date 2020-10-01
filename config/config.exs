use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    fusion: {Ueberauth.Strategy.Fusion, []}
  ]

config :ueberauth, Ueberauth.Strategy.Fusion.OAuth,
  client_id: "client_id",
  client_secret: "client_secret",
  token_url: "token_url",
  fusion_url: "http://fusion.url"
