$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "protokoll/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "protokoll"
  s.version     = Protokoll::VERSION
  s.authors     = ["Peter Bücker"]
  s.email       = ["naag@gmx.net"]
  s.homepage    = "https://github.com/naag/protokoll"
  s.summary     = "Change all Rails / Ruby logging to Logstash compatible JSON"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.1.0"

  s.add_development_dependency "sqlite3"
end
