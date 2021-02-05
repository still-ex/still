import Config

config :still,
  url_fingerprinting: true,
  base_url: "https://stillstatic.io",
  pass_through_copy: [
    ~r/.*jpe?g/,
    "subvisual.png",
    "images",
    "fonts",
    "CNAME"
  ]
