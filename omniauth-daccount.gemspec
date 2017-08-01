# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/daccount/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-daccount"
  spec.version       = OmniAuth::Daccount::VERSION
  spec.authors       = ["Koji Yamazaki"]
  spec.email         = ["kouji.yamazaki.cv@nttdocomo.com"]

  spec.summary       = %q{d-account Oauth2 strategy for OmniAuth 1.x}
  spec.description   = %q{d-account Oauth2 strategy for OmniAuth 1.x. This allows you to login to d-account with your ruby app}
  spec.homepage      = ""

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

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
