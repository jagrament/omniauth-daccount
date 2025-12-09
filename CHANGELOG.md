# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.4] - 2025-01-09

### Added
- CHANGELOG.md for tracking release history

### Changed
- Updated Ruby version requirement to >= 3.4.0 for Ruby 3.4.x compatibility
- Updated Rails compatibility to support Rails 7.2.3
- Modernized gemspec structure (using `__dir__` instead of `__FILE__`)
- Updated all development dependencies to latest versions compatible with Ruby 3.4.x
  - bundler: >= 2.0
  - rake: >= 13.0
  - rspec: ~> 3.12
  - simplecov: ~> 0.22
  - rack-test: ~> 2.1
  - webmock: ~> 3.18
- Updated runtime dependencies for Rails 7.2.3 compatibility
  - omniauth: >= 2.0
  - omniauth-oauth2: >= 1.8

### Removed
- Removed `multi_json` runtime dependency (not actually used, Ruby 3.4 uses native JSON)
- Removed `pry-byebug` development dependency (not used in codebase)
- Removed `.travis.yml` (outdated CI configuration)

### Fixed
- Ensured compatibility with Ruby 3.x keyword argument handling
- Ensured compatibility with Psych 4 YAML parser (Ruby 3.1+)

## [0.3.3] - 2020-05-12

### Changed
- Version bump to 0.3.3

## [0.3.2] - Earlier Release

### Added
- Initial OAuth2 authentication support for d-account
- OmniAuth strategy implementation
