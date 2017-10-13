require "log4r"
require 'optparse'
require "vagrant/redir/helper"

module Vagrant
  module Redir 
    module Command
      class Pids < Vagrant.plugin("2", :command)
        
        include Vagrant::Redir::Helper

        def initialize(argv, env)
          super
          @logger = Log4r::Logger.new("vagrant::redir::command::pids")
          @argv
          @env = env
        end

        def execute
          return help if @argv.include?("-h") || @argv.include?("--help")

          opts = OptionParser.new
          argv = parse_options(opts)
          @logger.debug("argv: #{argv}")

          with_target_vms(argv) do |vm|
            pids = stored_redir_pids(vm, check_is_running=true)
            if pids.any?
              @env.ui.info I18n.t("vagrant_redir.command.pids.list_title", name: vm.name)
              pids.each do |p|
                @env.ui.info I18n.t("vagrant_redir.command.pids.list_item", pid: p[:pid], host_port: p[:host_port], is_system_port: p[:is_system_port], is_running: p[:is_running])
              end
              @env.ui.info("")
            end
          end
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir pids [<name>]"
            opts.separator ""
            opts.separator "Show stored redir pids and appropriate processes states"
            opts.separator ""
            opts.separator " <name> - optional virtual machine name"
          end

          @env.ui.info(opts.help, :prefix => false)
        end

      end
    end
  end
end
