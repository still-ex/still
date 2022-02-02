import Config

config :still,
  dev_layout: true,
  ignore_files: [],
  watchers: []

config :still, Still.Preprocessor.Markdown, use_responsive_images: true
