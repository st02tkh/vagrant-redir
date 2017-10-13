require "log4r"
require 'optparse'
require "vagrant/redir/helper"

module Vagrant
  module Redir 
    module Command
      class Ps < Vagrant.plugin("2", :command)
        
        include Vagrant::Redir::Helper

        def initialize(argv, env)
          super
          @logger = Log4r::Logger.new("vagrant::redir::command::Ps")
          @argv
          @env = env
        end

        def execute
          return help if @argv.include?("-h") || @argv.include?("--help")

          opts = OptionParser.new
          argv = parse_options(opts)
          @logger.debug("argv: #{argv}")

          with_target_vms(argv) do |vm|
            pids = redir_pids_by_ip(vm)
            if pids.any?
              @env.ui.info I18n.t("vagrant_redir.command.ps.list_title", name: vm.name)
              pids.each do |p|
                @env.ui.info I18n.t("vagrant_redir.command.ps.list_item", pid: p[:pid], host_port: p[:host_port], is_system_port: p[:is_system_port])
              end
              @env.ui.info("")
            end
          end
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir ps [<name>]"
            opts.separator ""
            opts.separator "Show pids of running redir processes grepped by public IP"
            opts.separator ""
            opts.separator " <name> - optional virtual machine name"
          end

          @env.ui.info(opts.help, :prefix => false)
        end

      end
    end
  end
end
