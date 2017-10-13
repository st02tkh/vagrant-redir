require "log4r"
require 'optparse'
require "vagrant/redir/helper"

module Vagrant
  module Redir 
    module Command
      class Addr < Vagrant.plugin("2", :command)

        include Vagrant::Redir::Helper

        def initialize(argv, env)
          super
          @logger = Log4r::Logger.new("vagrant::redir::command::addr")
          @argv
          @env = env
        end

        def execute
          return help if @argv.include?("-h") || @argv.include?("--help")

          opts = OptionParser.new
          argv = parse_options(opts)
          @logger.debug("argv: #{argv}")
          
          if with_target_vms(argv) { }.count > 0
            @env.ui.info I18n.t("vagrant_redir.command.addr.list_title")
            with_target_vms(argv) do |vm|

              pub_ip = vm.provider.capability(:public_address)

              if vm.state.id != :running
                raise ::Vagrant::Redir::Errors::NotRunning
              end
              if pub_ip == nil
                raise ::Vagrant::Redir::Errors::Unknown
              end

              @env.ui.info I18n.t("vagrant_redir.command.addr.list_item", id: vm.id, name: vm.name, ip: pub_ip)

            end
          end
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir addr [<name>]"
            opts.separator ""
            opts.separator "Show VM's ID, name and public IP address"
            opts.separator ""
            opts.separator " <name> - optional virtual machine name"
          end

          @env.ui.info(opts.help, :prefix => false)
        end

      end
    end
  end
end
