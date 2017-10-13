require "log4r"
require 'optparse'
require "vagrant/redir/helper"

module Vagrant
  module Redir 
    module Command
      class Up < Vagrant.plugin("2", :command)
        
        include Vagrant::Redir::Helper

        def initialize(argv, env)
          super
          @logger = Log4r::Logger.new("vagrant::redir::command::up")
          @argv
          @env = env
        end

        def execute
          return help if @argv.include?("-h") || @argv.include?("--help")

          opts = OptionParser.new
          argv = parse_options(opts)
          @logger.debug("argv: #{argv}")

          with_target_vms(argv) do |vm|
            @env.ui.info I18n.t("vagrant_redir.command.up.list_title", name: vm.name)
            @logger.debug "VM #{vm.name}:"

            forwarded_ports = compile_forwarded_ports(vm.config)
            if forwarded_ports.any? and not redir_installed?
              raise Errors::RedirNotInstalled
            end

            # Warn if we're port forwarding to any privileged ports
            forwarded_ports.each do |fp|
              if fp[:host] <= 1024
                @env.ui.warn I18n.t("vagrant.actions.vm.forward_ports.privileged_ports")
                break
              end
            end

            if forwarded_ports.any?
              #@env.ui.info " " + I18n.t("vagrant.actions.vm.forward_ports.forwarding")
              forward_ports(forwarded_ports, vm)
            end
            @env.ui.info("")
          end
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir up [<name>]"
            opts.separator ""
            opts.separator "Setup port forwarding for vm(s)"
            opts.separator ""
            opts.separator " <name> - optional virtual machine name"
          end

          @env.ui.info(opts.help, :prefix => false)
        end


      end
    end
  end
end
