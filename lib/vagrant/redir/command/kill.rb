require "log4r"
require 'optparse'
require "vagrant/redir/helper"

module Vagrant
  module Redir 
    module Command
      class Kill < Vagrant.plugin("2", :command)
        
        include Vagrant::Redir::Helper

        def initialize(argv, env)
          super
          @logger = Log4r::Logger.new("vagrant::redir::command::kill")
          @argv
          @env = env
        end

        def execute
          return help if @argv.include?("-h") || @argv.include?("--help")

          opts = OptionParser.new
          argv = parse_options(opts)
          @logger.debug("argv: #{argv}")

          with_target_vms(argv) do |vm|
            @logger.debug "Killing redir processes for VM #{vm.name}:"
            ensure_killed_by_ip(vm)
          end
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir kill [<name>]"
            opts.separator ""
            opts.separator "Kill redir processes by stored pids and remove stoed pids"
            opts.separator ""
            opts.separator " <name> - optional virtual machine name"
          end

          @env.ui.info(opts.help, :prefix => false)
        end

      end
    end
  end
end
