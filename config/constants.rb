# frozen_string_literal: true

module Constants
  module App
    APP_ROOT = ENV.fetch("APP_ROOT")
  end

  module Templates
    PATH = File.join(Constants::App::APP_ROOT, "templates").freeze
    IMAGES_ROOT = File.join(Constants::App::APP_ROOT, "templates/images").freeze
  end
end
