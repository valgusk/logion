module Logion
  class LoggerPatcher
    attr_accessor :logger, :logion_instance

    def initialize(logion_instance)
      self.logion_instance = logion_instance
      self.logger          = logion_instance.logger

      additional_logging =  proc do |*args, &block|
        log_to_separate_file *args, &block
      end

      logger.instance_variable_set '@additional_logging', additional_logging

      # we don't want to ruin your pretty logger, so lets extend it
      def logger.add(*args, &block)
        @additional_logging.call(*args, &block)
        super
      end
    end

    def severity_colors(severity_name)
      {
          WARN:    [:black, :yellow],
          DEBUG:   [:white, :blue],
          INFO:    [:black, :green],
          FATAL:   [:white, :red],
          ERROR:   [:black, :light_red],
          UNKNOWN: [:white, :black]
      }[severity_name]
    end

    def format_log_entry(severity, message = nil, progname = nil, *_rest)
      message ||= progname

      severity_name = Logger::Severity.constants.find do |name|
        Logger::Severity.const_get(name) == severity
      end

      color, background = severity_colors(severity_name)

      prefix = "#{ Process.pid } #{ '%10s' % "(#{ severity_name })" }:"
      prefix = ::Logion::Logion.colorize(prefix, color: color, background: background)

      "#{ prefix } #{ message }"
    end

    def log_to_separate_file(*args, &block)
      info_file = logion_instance.log_path_holder

      if File.exists?(info_file)
        separate_log    = File.read(info_file)
        formatted_entry = format_log_entry(*args, &block)
        open(separate_log, 'a') { |f| f.puts formatted_entry }
      end
    end
  end
end
