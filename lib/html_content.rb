# frozen_string_literal: true

class HtmlContent
  include ErbTemplate

  class Error < StandardError; end
  class HtmlFileMissing < Error; end
  class HtmlTemplateNameMissing < Error; end

  OPTIONAL_PARTS = %i[header footer].freeze

  attr_reader :body_config,
              :header_config,
              :footer_config,
              :body_content,
              :header_content,
              :footer_content,
              :template_data

  def initialize(body:, header: {}, footer: {}, template_data: {})
    @body_config = body
    @header_config = header
    @footer_config = footer
    @template_data = template_data
  end

  def initialize_content
    %i[body header footer].each do |part|
      config = public_send("#{part}_config")
      config.key?(:path) ? read_html_file(config[:path], part) : generate_html_content(config, part)
    end
    self
  end

  private

  alias pdf_data template_data

  def read_html_file(relative_path, part)
    html_file_path = File.join(Constants::Templates::PATH, relative_path)
    raise HtmlFileMissing, "file path: #{html_file_path}" unless File.exist?(html_file_path)

    instance_variable_set("@#{part}_content", File.read(html_file_path))
  end

  # { template: "content", layout: "layouts/default" }
  def generate_html_content(config, part)
    content = ""
    raise HtmlTemplateNameMissing, "key `template` missing" unless template_present_or_optional?(config, part)

    content = generate_html(**config) if config.key?(:template)

    instance_variable_set("@#{part}_content", content)
  end

  def template_present_or_optional?(config, part)
    config.key?(:template) || OPTIONAL_PARTS.include?(part)
  end
end
