$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "logion/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "logion"
  s.version     = Logion::VERSION
  s.authors     = ['Valery Guskov']
  s.email       = ['valerijs.gusjkovs@gmail.com']
  s.homepage    = nil
  s.summary     = 'Output logs per example'
  s.description = 'A hacky gem to output per-example logs'
  s.licenses    = ['MIT']

  s.files = Dir["{config,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_runtime_dependency 'rails',       '~> 3.2'
  s.add_runtime_dependency 'rspec-rails', '~> 3.2'
  s.add_runtime_dependency 'colorize',    '~> 0.7.7'
end
