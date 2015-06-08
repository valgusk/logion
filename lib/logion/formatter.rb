require 'rspec'
require 'rspec/core/formatters/base_formatter'

module Logion
  class Formatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :example_failed, :dump_failures

    def initialize(output)
      @output = output
    end

    def example_failed(notification)
      show_failure_debug_info(notification.example)
    end

    def dump_failures(notification)
      return if notification.failure_notifications.empty?
      notification.examples.each do |example|
        next unless example.exception
        show_failure_debug_info(example)
      end
    end

    private

    def show_failure_debug_info(example)
      @output.puts('----------------------------'.colorize(:yellow))
      @output.puts(example.rerun_argument.colorize(color: :yellow, background: :blue))
      @output.puts(example.metadata[:log_location].to_s.colorize(color: :white, background: :blue))
      if example.metadata[:screenshot].is_a?(Hash)
        example.metadata[:screenshot].each do |type, path|
          colorful_type = type.to_s.colorize(color: :black, background: :white)
          colorful_path = path.to_s.colorize(color: :black, background: :light_blue)
          @output.puts("#{ colorful_type } #{ colorful_path }")
        end
      end
    end
  end
end