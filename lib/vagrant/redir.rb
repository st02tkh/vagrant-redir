require "vagrant/redir/version"
require "vagrant/redir/plugin"

module Vagrant
  module Redir
    def self.source_root
      @source_root ||= Pathname.new(File.dirname(__FILE__)).join('..').expand_path
    end
  end
end
