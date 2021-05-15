import Config

config :still,
  url_fingerprinting: true,
  pass_through_copy: [
    ~r/.*jpe?g/,
    "subvisual.png",
    "images",
    "fonts",
    "CNAME"
  ]
