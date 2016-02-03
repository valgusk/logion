module Logion
  super_class = if Object.const_defined?('Rails')
    ::Rails::Engine
  else
    Object
  end

  class Engine < super_class
    require 'colorize'
    require 'rspec'
    require 'rspec/core/formatters/base_formatter'
    require 'logion/formatter'
    require 'logion/logger_patcher'
  end
end
