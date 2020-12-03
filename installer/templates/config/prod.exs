import Config

config :still,
  dev_layout: false,
  url_fingerprinting: true,
  # change this to your production endpoint
  base_url: raise(":base_url not set")
