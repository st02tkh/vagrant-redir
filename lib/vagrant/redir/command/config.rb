require "log4r"
require 'optparse'
require "vagrant/redir/helper"

module Vagrant
  module Redir 
    module Command
      class Config < Vagrant.plugin("2", :command)

        include Vagrant::Redir::Helper

        def initialize(argv, env)
          super
          @logger = Log4r::Logger.new("vagrant::redir::command::config")
          @argv
          @env = env
        end

        def execute
          return help if @argv.include?("-h") || @argv.include?("--help")

          opts = OptionParser.new
          argv = parse_options(opts)
          @logger.debug("argv: #{argv}")

          with_target_vms(argv) do |vm|
            if compile_forwarded_ports(vm.config).any?
              @env.ui.info I18n.t("vagrant_redir.command.config.list_title", name: vm.name)
              compile_forwarded_ports(vm.config).each do |record|
                  r = record.delete(:id)
                  s = record.collect do |k, v|
                      "#{k}: #{v}"
                  end.join('; ')
                  @env.ui.info(" #{s}")
              end
              @env.ui.info("")
            end
          end
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir config [<name>]"
            opts.separator ""
            opts.separator "Show port forwarding configuration"
            opts.separator ""
            opts.separator " <name> - optional virtual machine name"
          end

          @env.ui.info(opts.help, :prefix => false)
        end

      end
    end
  end
end
