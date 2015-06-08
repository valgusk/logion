module Logion
  class LoggerPatcher
    attr_accessor :logger, :logion_instance

    def initialize(logion_instance)
      self.logion_instance = logion_instance
      self.logger          = logion_instance.options[:logger].call

      additional_logging =  proc do |*args, _block|
        log_to_separate_file *args
      end

      logger.instance_variable_set '@additional_logging', additional_logging

      def logger.add(*args, &block)
        @additional_logging.call(*args, block)
        super
      end
    end

    def log_to_separate_file(severity, message, progname, *_rest)
      message ||= progname
      info_file = logion_instance.options[:log_path_holder].call

      if File.exists?(info_file)
        separate_log = File.read(info_file)

        severity_name = Logger::Severity.constants.find do |name|
          Logger::Severity.const_get(name) == severity
        end

        color, background = {
          WARN:    [:black, :yellow],
          DEBUG:   [:white, :blue],
          INFO:    [:black, :green],
          FATAL:   [:white, :red],
          ERROR:   [:black, :light_red],
          UNKNOWN: [:white, :black]
        }[severity_name]

        severity_name = '%10s' % "(#{ severity_name })"

        prefix = "#{ Process.pid } #{ severity_name }:".colorize(color: color, background: background)
        open(separate_log, 'a') { |f| f.puts "#{ prefix } #{ message }" }
      end
    end
  end
end