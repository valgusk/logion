require "logion/engine"

module Logion
  class Logion
    attr_accessor :options

    def self.colorize(string, *args, &block)
      return string if Object.const_defined?(:Colored)
      string.colorize(*args, &block)
    end

    DEFAULT_CONFIG = {
      split_per_occurance: true,
      log_path_holder:     -> { Pathname.new('tmp').join ".current_spec_log_path#{ ENV['TEST_ENV_NUMBER'] }" },
      log_base:            -> { Pathname.new('tmp').join 'log', "tests#{ ENV['TEST_ENV_NUMBER'] }" },
      add_hooks:           ->(logion) { fail "Rspec not present!" },
      logger:              -> { fail 'No logger provided' },
      separator:           lambda do |logion, example, action|
        path = example.respond_to?(:rerun_argument) ? example.rerun_argument : example.location
        logion.logger.debug colorize("#{ path } #{ action }:", color: :white, background: :red)
      end,
      patcher_class:       ::Logion::LoggerPatcher
    }

    RAILS_DEFAULTS = {
      log_path_holder:     -> { Rails.root.join 'tmp', ".current_spec_log_path#{ ENV['TEST_ENV_NUMBER'] }" },
      log_base:            -> { Rails.root.join 'tmp', 'log', "tests#{ ENV['TEST_ENV_NUMBER'] }" },
      logger:              -> { Rails.logger }
    }

    RSPEC_DEFAULTS = {
      add_hooks:           ->(logion) { logion.configure_rspec },
    }

    [DEFAULT_CONFIG, RAILS_DEFAULTS, RSPEC_DEFAULTS].flat_map(&:keys).each do |param|
      define_method param do |*args|
        if self.options[param].is_a?(Proc)
          proc = self.options[param]
          proc.(*[self, *args].first(proc.arity))
        else
          self.options[param]
        end
      end
    end

    def initialize(init_options = {})
      defaults = DEFAULT_CONFIG

      if Object.const_defined?('Rails')
        defaults.merge! RAILS_DEFAULTS
      end

      if Object.const_defined?('RSpec')
        defaults.merge! RSPEC_DEFAULTS
      end

      self.options = defaults.merge init_options
      add_hooks
    end

    def configure_rspec
      me = self
      formatter_klass = ::Logion::Formatter

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
      FileUtils.rm_f log_path_holder
      FileUtils.remove_dir log_base, force: true
      @log_patcher = patcher_class.new self
    end

    def before(example)
      path = example.respond_to?(:rerun_argument) ? example.rerun_argument : example.location
      relative_path = path.sub(/:(\d+)$/, '/\1.log')
      location      = log_base.join(relative_path)
      location      = safe_location(location, relative_path)

      location.dirname.mkpath
      example.metadata[:log_location] = location
      File.write(log_path_holder, location.to_s)
      separator example, :start
    end

    def after(example)
      separator example, :end
      FileUtils.rm log_path_holder
    end

    private

    def safe_location(location, relative_path)
      uniq_location = location
      if split_per_occurance
        suffix        = 0

        while File.exists? uniq_location
          suffix += 1
          safe_relative_path = relative_path.sub(/\.log$/, ".#{ suffix }.log")
          uniq_location      = log_base.join safe_relative_path
        end
      end
      uniq_location
    end
  end
end
