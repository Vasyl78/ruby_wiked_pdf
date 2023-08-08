# frozen_string_literal: true

$LOAD_PATH.unshift(
  File.expand_path("..", __dir__),
  File.expand_path("../lib", __dir__)
)

ENV["RACK_ENV"] = "production"

ENV["APP_ROOT"] = File.expand_path("..", __dir__)
