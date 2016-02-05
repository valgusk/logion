module Logion
  class Formatter < RSpec::Core::Formatters::BaseFormatter
    if RSpec::Core::Formatters.respond_to?(:register)
      RSpec::Core::Formatters.register self, :example_failed, :dump_failures
    end

    def initialize(output)
      super(output)
      @output = output
    end

    def example_failed(info)
      if info.is_a?(RSpec::Core::Example)
        super(info)
        example_failed_example(info)
      else
        example_failed_notification(info)
      end
    end

    def dump_failures(notification = nil)
      if notification
        dump_failures_notification(notification)
      else
        dump_failures_example
      end
    end

    # rspec 2.99
    def example_failed_example(example)
      show_failure_debug_info(example)
    end

    def dump_failures_example
      return if failed_examples.empty?
      failed_examples.each do |example|
        next unless example.exception
        show_failure_debug_info(example)
      end
    end

    # rspec 3.x
    def example_failed_notification(notification)
      show_failure_debug_info(notification.example)
    end

    def dump_failures_notification(notification)
      return if notification.failure_notifications.empty?
      notification.examples.each do |example|
        next unless example.exception
        show_failure_debug_info(example)
      end
    end

    private

    def show_failure_debug_info(example)
      path = example.respond_to?(:rerun_argument) ? example.rerun_argument : example.location

      @output.puts(::Logion::Logion.colorize('----------------------------', color: :yellow))
      @output.puts(::Logion::Logion.colorize(path, color: :yellow, background: :blue))
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
