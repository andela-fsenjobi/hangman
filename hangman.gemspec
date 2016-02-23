# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hangman/version'

Gem::Specification.new do |spec|
  spec.name          = 'hangman'
  spec.version       = Hangman::VERSION
  spec.authors       = ['andela-fsenjobi']
  spec.email         = ['femi.senjobi@andela.com']

  spec.summary       = "It is a do or die affiar. Get the words or you'll be hanged"
  spec.description   = "This gem is an implementation of the hangman game.\nAttempt to guess the missing letters correctly.\nYou have a limited number of tries.\nIf you use up all your chances without getting the word correctly,\nyou will be hanged."
  spec.homepage      = 'https://hangman.me'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
