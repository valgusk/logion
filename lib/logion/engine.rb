module Logion
  class Engine < ::Rails::Engine
    require 'colorize'
    require 'logion/formatter'
    require 'logion/logger_patcher'
  end
end
