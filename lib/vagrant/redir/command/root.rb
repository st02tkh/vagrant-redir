module Vagrant
  module Redir 
    module Command
      class Root < Vagrant.plugin("2", :command)
        def self.synopsis
          'vagrant-redir specific commands'
        end

        def initialize(argv, env)
          @args, @sub_command, @sub_args = split_main_and_subcommand(argv)
          @subcommands = Vagrant::Registry.new.tap do |registry|
            registry.register(:addr) do
              require_relative 'addr'
              Addr 
            end
            registry.register(:config) do
              require_relative 'config'
              Config 
            end
            registry.register(:ps) do
              require_relative 'ps'
              Ps
            end
            registry.register(:kill) do
              require_relative 'kill'
              Kill
            end
            registry.register(:status) do
              require_relative 'status'
              Status
            end
            registry.register(:down) do
              require_relative 'down'
              Down 
            end
            registry.register(:up) do
              require_relative 'up'
              Up             
            end
            registry.register(:pids) do
              require_relative 'pids'
              Pids
            end
          end
          super(argv, env)
        end

        def execute
          # Print the help
          return help if @args.include?("-h") || @args.include?("--help")

          klazz = @subcommands.get(@sub_command.to_sym) if @sub_command
          return help unless klazz

          @logger.debug("Executing command: #{klazz} #{@sub_args.inspect}")

          # Initialize and execute the command class
          klazz.new(@sub_args, @env).execute
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant redir <subcommand> [<args>]"
            opts.separator ""
            opts.separator "Available subcommands:"

            keys = []
            @subcommands.each { |key, value| keys << key }

            keys.sort.each do |key|
              opts.separator "    #{key}"
            end

            opts.separator ""
            opts.separator "For help on any individual subcommand run `vagrant redir <subcommand> -h`"
          end

          @env.ui.info(opts.help, :prefix => false)
        end

      end
    end
  end
end
