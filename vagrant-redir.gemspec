# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vagrant/redir/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-redir"
  spec.version       = Vagrant::Redir::VERSION
  spec.authors       = ["st02tkh"]
  spec.email         = ["st02tkh@gmail.com"]

  spec.summary       = %q{vagrant-redir plugin allows to manage redir's ports forwarding used by vagrant-lxc provider.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/st02tkh/vagrant-redir"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

end
