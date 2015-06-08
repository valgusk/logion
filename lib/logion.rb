require "logion/engine"

module Logion
  class Logion
    attr_accessor :options

    DEFAULT_CONFIG = {
      split_per_occurance: true,
      log_path_holder:     -> { Rails.root.join 'tmp', ".current_spec_log_path#{ ENV['TEST_ENV_NUMBER'] }" },
      log_base:            -> { Rails.root.join 'tmp', 'log', "tests#{ ENV['TEST_ENV_NUMBER'] }" },
      add_hooks:           ->(logion) { logion.configure_rspec },
      logger:              -> { Rails.logger },
      separator:           lambda do |example, action|
        Rails.logger.debug "#{ example.rerun_argument } #{ action }:".colorize(color: :white, background: :red)
      end
    }

    def initialize(init_options = {})
      self.options = DEFAULT_CONFIG.merge init_options

      options[:add_hooks].call self
    end

    def configure_rspec
      me = self
      formatter_klass = Formatter

      RSpec.configure do |config|
        config.add_formatter(formatter_klass)

        config.before(:suite) do
          me.init
        end

        config.before(:each) do |example|
          me.before(example)
        end

        config.after(:each) do |example|
          me.after(example)
        end
      end
    end

    def init
      FileUtils.rm_f options[:log_path_holder].call
      FileUtils.remove_dir options[:log_base].call, force: true
      @log_patcher = LoggerPatcher.new self
    end

    def before(example)
      relative_path = example.rerun_argument.sub(/:(\d+)$/, '/\1.log')
      location      = options[:log_base].call.join(relative_path)
      location      = safe_location(location, relative_path)

      location.dirname.mkpath
      example.metadata[:log_location] = location
      File.write(options[:log_path_holder].call, location.to_s)
      options[:separator].(example, :start)
    end

    def after(example)
      options[:separator].(example, :end)
      FileUtils.rm options[:log_path_holder].call
    end

    private

    def safe_location(location, relative_path)
      safe_location = location
      if options[:split_per_occurance]
        suffix        = 0

        while File.exists? safe_location
          suffix += 1
          safe_relative_path = relative_path.sub(/\.log$/, ".#{ suffix }.log")
          safe_location = options[:log_base].call.join safe_relative_path
        end
      end
      safe_location
    end
  end
end
