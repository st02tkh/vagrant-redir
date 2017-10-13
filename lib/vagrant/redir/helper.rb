module Vagrant
  module Redir 
    module Helper 

        def redirect_port(host_ip, host_port, guest_ip, guest_port)
          params = %W( --lport=#{host_port} --caddr=#{guest_ip} --cport=#{guest_port} )
          params.unshift "--laddr=#{host_ip}" if host_ip
          params << '--syslog' if ENV['REDIR_LOG']
          if host_port < 1024
            redir_cmd = "sudo redir #{params.join(' ')} 2>/dev/null"
          else
            redir_cmd = "redir #{params.join(' ')} 2>/dev/null"
          end
          @logger.debug "Forwarding port with `#{redir_cmd}`"
          spawn redir_cmd
        end

        def store_redir_pid(host_port, redir_pid, vm)
          data_dir = vm.data_dir.join('pids')
          data_dir.mkdir unless data_dir.directory?

          data_dir.join("redir_#{host_port}.pid").open('w') do |pid_file|
            pid_file.write(redir_pid)
          end
        end

        def redir_installed?
          system "which redir > /dev/null"
        end

        # from vagrant-lxc/action/forward_ports
        def compile_forwarded_ports(config)
          mappings = {}

          config.vm.networks.each do |type, options|
            next if options[:disabled]

            # TODO: Deprecate this behavior of "automagically" skipping ssh forwarded ports
            if type == :forwarded_port && options[:id] != 'ssh'
              if options.fetch(:host_ip, '').to_s.strip.empty?
                options[:host_ip] = '127.0.0.1'
              end
              mappings[options[:host]] = options
            end
          end

          mappings.values
        end

        def forward_ports(fports, vm)
          fports.each do |fp|
            message_attributes = {
              # TODO: Add support for multiple adapters
              :adapter    => 'eth0',
              :guest_port => fp[:guest],
              :host_port  => fp[:host]
            }

            # TODO: Remove adapter from logging
            @env.ui.info(" " + I18n.t("vagrant.actions.vm.forward_ports.forwarding_entry", message_attributes))

            redir_pid = redirect_port(
              fp[:host_ip],
              fp[:host],
              fp[:guest_ip] || vm.provider.ssh_info[:host],
              fp[:guest]
            )
            store_redir_pid(fp[:host], redir_pid, vm)
          end
        end

        def store_redir_pid(host_port, redir_pid, vm)
          data_dir = vm.data_dir.join('pids')
          data_dir.mkdir unless data_dir.directory?

          data_dir.join("redir_#{host_port}.pid").open('w') do |pid_file|
            pid_file.write(redir_pid)
          end
        end

        def redir_installed?
          system "which redir > /dev/null"
        end

        def is_redir_pid?(pid)
          @logger.debug "Checking if #{pid} is a redir process with `ps -o cmd= #{pid}`"
          `ps -o cmd= #{pid}`.strip.chomp =~ /redir/
        end

        def is_redir_running?(pid)
            !is_redir_pid?(pid).nil?
        end

        def stored_redir_pids(vm, check_is_running=false,
                                  remove_inactive=false)
          check_is_running = true if remove_inactive
          @logger.debug "check_is_running: #{check_is_running}; remove_inacrtive=#{remove_inactive}"
          Dir[vm.data_dir.join('pids').to_s + "/redir_*.pid"].map do |file|
            pid = File.read(file).strip.chomp
            if check_is_running
              is_redir_pid = is_redir_running?(pid)
              is_running = is_redir_running?(pid)
              @logger.debug "is_redir_pid: #{is_redir_pid} is_running: #{is_running}"
              unless is_running 
                @logger.debug "HERE is_running: #{is_running}"
                if remove_inactive
                  @logger.debug "HERE remove_inactive: #{remove_inactive}"
                  File.delete file
                  nil
                  next
                end
              end
            end
            port_number = File.basename(file).split(/[^\d]/).join
            @logger.debug "HERE port_number: #{port_number}"
            h = {
              pid: pid,
              is_system_port: Integer(port_number) <= 1024,
              host_port: port_number,
              pid_file: file
            }
            h[:is_running] = is_running if check_is_running
            h
          end.reject(&:nil?)
        end

        def remove_redir_pids(vm)
          Dir[vm.data_dir.join('pids').to_s + "/redir_*.pid"].each do |file|
            File.delete file
          end
        end

        def remove_inactive_redir_pids(vm)
          Dir[vm.data_dir.join('pids').to_s + "/redir_*.pid"].each do |file|
            pid = File.read(file).strip.chomp
            File.delete file unless is_redir_running?(pid)
          end
        end

        def kill_by_stored_pids(vm, signal="TERM")
          if stored_redir_pids(vm).any?
            stored_redir_pids(vm).each do |p|
              next unless is_redir_pid?(p[:pid])
              @logger.debug "#{signal}ing pid #{p[:pid]}"
              if p[:is_system_port]
                system "sudo pkill -#{signal} -P #{p[:pid]}"
              else
                system "pkill -#{signal} -P #{p[:pid]}"
              end
            end

            @logger.info "Removing inactive redir pids files for vm #{vm.name}"
            remove_inactive_redir_pids(vm)
          else
            @logger.info "No redir pids found for vm #{vm.name}"
          end
        end

        def ensure_killed_by_stored_pids(vm)
            kill_by_stored_pids(vm, signal="TERM")
            kill_by_stored_pids(vm, signal="KILL")
        end

        def redir_pids_by_ip(vm)
          pub_ip = vm.provider.capability(:public_address)
          if pub_ip != nil
            `pgrep -a redir | grep "caddr=#{pub_ip}"`.strip.chomp.split(/\n+/).collect do |item|
                ar = item.split
                {
                  pid:   ar[0],

                  laddr: ar[2].split("=")[1],
                  host_ip: ar[2].split("=")[1],

                  lport: ar[3].split("=")[1],
                  host_port: ar[3].split("=")[1],
                  is_system_port: Integer(ar[3].split("=")[1]) <= 1024,

                  caddr: ar[4].split("=")[1],
                  guest_ip: ar[4].split("=")[1],

                  cport: ar[5].split("=")[1],
                  guest_port: ar[5].split("=")[1],
                }
            end
          end
        end

        def kill_by_ip(vm, signal="TERM")
          if redir_pids_by_ip(vm).any?
            redir_pids_by_ip(vm).each do |p|
              next unless is_redir_running?(p[:pid])
              @logger.debug "#{signal}ing pid #{p[:pid]}"
              @env.ui.info "#{signal}ing pid #{p[:pid]}"
              if p[:is_system_port]
                system "sudo pkill -#{signal} -P #{p[:pid]}"
              else
                system "pkill -#{signal} -P #{p[:pid]}"
              end
            end
          end
        end

        def ensure_killed_by_ip(vm)
            kill_by_ip(vm, signal="TERM")
            kill_by_ip(vm, signal="KILL")
        end
    end
  end
end
