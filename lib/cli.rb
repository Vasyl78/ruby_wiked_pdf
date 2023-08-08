# frozen_string_literal: true

class CLI
  STATUS_SUCCESS  = 0
  STATUS_OFFENSES = 1
  STATUS_ERROR    = 2

  class Finished < RuntimeError; end

  attr_reader :options,
              :service_options

  def initialize
    @options = {}
  end

  def run(args = ARGV)
    @options = Options.new.parse(args)
    @service_options = OptionsMapper.call(options)
    GeneratePdf.new(**service_options).generate
    STATUS_SUCCESS
  rescue OptionArgumentError => e
    handle_errors(e.message)
  rescue Finished
    STATUS_SUCCESS
  rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption => e
    handle_errors(e.message, "For usage information, use --help")
  rescue StandardError, SyntaxError, LoadError => e
    handle_errors(e.message, e.backtrace)
  end

  def handle_errors(*errors)
    errors.each { |err| warn err }
    STATUS_ERROR
  end
end
