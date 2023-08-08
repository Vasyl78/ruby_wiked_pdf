# frozen_string_literal: true

require "optparse"
require "shellwords"

class CLI
  class OptionArgumentError < StandardError; end

  class Options
    ORIENTATIONS = %w[Landscape Portrait].freeze

    def initialize
      @options = {}
      @validator = OptionsValidator.new(options)
    end

    def parse(command_line_args)
      args = command_line_args
      define_options.parse!(args)

      validator.validate_compatibility

      options
    end

    private

    attr_reader :options,
                :validator

    def define_options
      OptionParser.new do |opts|
        opts.banner = "Usage: bin/wikedpdf_generate_pdf [options]"

        add_body_options(opts)
        add_header_options(opts)
        add_footer_options(opts)
        add_pdf_margins_options(opts)

        option(opts, "--orientation ORIENTATION") do |orientation|
          unless ORIENTATIONS.include?(orientation)
            raise OptionArgumentError,
                  "orientationfile one of Landscape or Portrait"
          end
        end

        option(opts, "--template-data JSON") do |args|
          @options[:template_data] = MultiJson.load(args, symbolize_keys: true)
        rescue MultiJson::ParseError => e
          raise OptionArgumentError, "template-data #{e.message}"
        end
      end
    end

    def option(opts, *args)
      long_opt_symbol = long_opt_symbol(args)
      args += Array(OptionsHelp::TEXT[long_opt_symbol])
      opts.on(*args) do |arg|
        @options[long_opt_symbol] = arg
        yield arg if block_given?
      end
    end

    def long_opt_symbol(args)
      long_opt = args.find { |arg| arg.start_with?("--") }
      long_opt[2..].sub("[no-]", "").sub(/ .*/, "").tr("-", "_").gsub(/[\[\]]/, "").to_sym
    end

    def add_body_options(opts)
      option(opts, "--body-html HTML")
      option(opts, "--body-template TEMPLATE")
      option(opts, "--body-layout LAYOUT")
      option(opts, "--[no-]skip-body-layout")
    end

    def add_header_options(opts)
      option(opts, "--header-html HTML")
      option(opts, "--header-template TEMPLATE")
      option(opts, "--header-layout LAYOUT")
      option(opts, "--[no-]skip-header-layout")
    end

    def add_footer_options(opts)
      option(opts, "--footer-html HTML")
      option(opts, "--footer-template TEMPLATE")
      option(opts, "--footer-layout LAYOUT")
      option(opts, "--[no-]skip-footer-layout")
    end

    def add_pdf_margins_options(opts)
      option(opts, "--margin-bottom UNITREAL", Integer)
      option(opts, "--margin-left UNITREAL", Integer)
      option(opts, "--margin-right UNITREAL", Integer)
      option(opts, "--margin-top UNITREAL", Integer)
    end
  end

  class OptionsValidator
    OPTIONAL_FILE_OPTIONS = %i[
      body_layout
      header_html
      header_template
      header_layout
      footer_html
      footer_template
      footer_layout
    ].freeze

    def initialize(options)
      @options = options
    end

    def validate_compatibility
      raise OptionArgumentError, "body-html or body-template must exist" unless body_html_or_template_present?

      valiate_optional_options!
    end

    private

    attr_reader :options

    def body_html_or_template_present?
      (options.key?(:body_html) &&
        validate_path!(File.join(Constants::Templates::PATH, options[:body_html]), "body-html")) ||
        (options.key?(:body_template) &&
          validate_path!(File.join(Constants::Templates::PATH, options[:body_template]), "body-html"))
    end

    def valiate_optional_options!
      OPTIONAL_FILE_OPTIONS.each do |file_option|
        next unless options.key?(file_option)

        path = File.join(Constants::Templates::PATH, options[file_option])
        option_name = file_option.to_s.tr("_", "-")
        validate_path!(path, option_name)
      end
    end

    def validate_path!(path, option)
      return true if file_exists?(path)

      raise OptionArgumentError, "#{option} file must exist"
    end

    def file_exists?(path)
      File.exist?(path) && !File.directory?(path)
    end
  end

  module OptionsHelp
    TEXT = {
      body_html: "Adds a html body by provided relative path",
      body_template: "Relative path to body template",
      body_layout: "Relative path to body layout",
      skip_body_layout: "Skip layout for body generation",
      header_html: "Adds a html header by provided relative path",
      header_template: "Relative path to header template",
      header_layout: "Relative path to footer layout",
      skip_header_layout: "Skip layout for header generation",
      footer_html: "Adds a html footer by provided relative path",
      footer_template: "Relative path to footer template",
      footer_layout: "Relative path to footer layout",
      skip_footer_layout: "Skip layout for footer generation",
      margin_bottom: "Set the page bottom margin",
      margin_left: "Set the page left margin (default 10mm)",
      margin_right: "Set the page right margin (default 10mm)",
      margin_top: "Set the page top margin",
      orientation: [
        "Set orientation to Landscape or Portrait",
        "(default Portrait)"
      ],
      template_data: "JSON Data for pdf content"
    }.freeze
  end
end
