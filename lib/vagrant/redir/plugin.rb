require 'vagrant'

module Vagrant
  module Redir 
    autoload :Errors, File.expand_path("../errors", __FILE__)

    class Plugin < Vagrant.plugin("2")
      name "vagrant-redir"
      description <<-EOF
      Manages redir's utility port forwading used by LXC provider
      EOF

      command "redir" do
        require_relative 'command/root'
        init!
        Command::Root
      end

      protected

      def self.init!
        return if defined?(@_init)
        I18n.load_path << File.expand_path(File.dirname(__FILE__) + '/../../../locales/en.yml')
        I18n.reload!
        @_init = true
      end

    end
  end
end
