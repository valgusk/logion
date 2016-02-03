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
      @output.puts(::Logion::Logion.colorize('----------------------------', color: :yellow))
      @output.puts(::Logion::Logion.colorize(example.rerun_argument, color: :yellow, background: :blue))
      @output.puts(::Logion::Logion.colorize(example.metadata[:log_location].to_s, color: :white, background: :blue))
      if example.metadata[:screenshot].is_a?(Hash)
        example.metadata[:screenshot].each do |type, path|
          colorful_type = ::Logion::Logion.colorize(type.to_s, color: :black, background: :white)
          colorful_path = ::Logion::Logion.colorize(path.to_s, color: :black, background: :light_blue)
          @output.puts("#{ colorful_type } #{ colorful_path }")
        end
      end
    end
  end
end
