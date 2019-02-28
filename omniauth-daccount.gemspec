# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/daccount/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-daccount"
  spec.version       = OmniAuth::Daccount::VERSION
  spec.authors       = ["Koji Yamazaki"]
  spec.email         = ["kouji.yamazaki.cv@nttdocomo.com"]

  spec.summary       = %q{d-account Oauth2 strategy for OmniAuth.}
  spec.description   = %q{d-account Oauth2 strategy for OmniAuth. This allows you to login to d-account with your ruby app}
  spec.homepage      = "https://github.com/jagrament/omniauth-daccount"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'omniauth', '>= 1.1.1'
  spec.add_runtime_dependency 'omniauth-oauth2', '>= 1.3.1'
  spec.add_runtime_dependency 'multi_json', '~> 1.3'

end
