# frozen_string_literal: true

class CLI
  class OptionsMapper
    MAPPING = {
      body_html: %i[html_config body path],
      body_template: %i[html_config body template],
      body_layout: %i[html_config body layout],
      skip_body_layout: %i[html_config body skip_layout],
      header_html: %i[html_config header path],
      header_template: %i[html_config header template],
      header_layout: %i[html_config header layout],
      skip_header_layout: %i[html_config header skip_layout],
      footer_html: %i[html_config footer path],
      footer_template: %i[html_config footer template],
      footer_layout: %i[html_config footer layout],
      skip_footer_layout: %i[html_config footer skip_layout],
      margin_bottom: %i[pdf_config margin bottom],
      margin_left: %i[pdf_config margin left],
      margin_right: %i[pdf_config margin right],
      margin_top: %i[pdf_config margin top],
      orientation: %i[pdf_config orientation],
      template_data: %i[template_data]
    }.freeze

    def self.call(options)
      new(options).perform
    end

    def initialize(options)
      @options = options
      @out_options = {}
    end

    def perform
      MAPPING.each_pair do |option_key, out_path|
        next unless options.key?(option_key)

        insert_value_by_path(options[option_key], out_options, out_path)
      end
      out_options
    end

    private

    attr_reader :options,
                :out_options

    def insert_value_by_path(value, storage, path)
      if path.size > 1
        storage[path[0]] ||= {}
        insert_value_by_path(value, storage[path[0]], path[1..])
      else
        storage_key = path.first
        storage_value = value
        storage_value.gsub!(/.html.erb\z/, "") if %i[template layout].include?(storage_key)
        storage[storage_key] = storage_value
      end
    end
  end
end
