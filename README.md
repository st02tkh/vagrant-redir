# vagrant-redir

This plugin allows to manage redir's ports forwarding used by vagrant-lxc provider.

## Installation

Add this line to your application's Gemfile:

```shell
$ vagrant plugin install vagrant-redir
```
or 

```shell
$ git clone https://github.com/st02tkh/vagrant-redir.git
$ cd vagrant-redir
$ gem build vagrant-redir.gemspec
$ vagrant plugin install ./vagrant-redir-X.Y.Z.gem
```

## Usage

Show available subcommands: 

```shell
$ vagrant redir <subcommand>
```

Shows a help for a subcommand run it with '-h':

```shell
$ vagrant redir <subcommand> -h
```


### addr

Shows a list of running VM's ID, name and public IP (or 'NONE' value if not set).

```shell
$ vagrant redir addr
```

will show:

```shell
List of VM(s) public IP addresses:
 id: xdg_1506653541513_93050; name: xdg; ip: 10.0.3.173
 id: db1_1506915461158_4146; name: db1; ip: 10.0.3.55
```

or for particular VM:

```shell
$ vagrant redir addr [<name>]
```



### config

Shows a list of VMs with a list of forwarded port for it:

```shell
$ vagrant redir config
```

will show:

```shell
Port forwarding configuration for VM 'xdg':
 guest: 8000; host: 8900; host_ip: 0.0.0.0; protocol: tcp
 guest: 8001; host: 8901; host_ip: 0.0.0.0; protocol: tcp
 guest: 80; host: 8908; host_ip: 0.0.0.0; protocol: tcp
 guest: 22; host: 8902; host_ip: 0.0.0.0; protocol: tcp

Port forwarding configuration for VM 'db1':
 guest: 8000; host: 9000; host_ip: 0.0.0.0; protocol: tcp
 guest: 8001; host: 9001; host_ip: 0.0.0.0; protocol: tcp
 guest: 80; host: 9080; host_ip: 0.0.0.0; protocol: tcp
 guest: 22; host: 9022; host_ip: 0.0.0.0; protocol: tcp
```
or for particular VM:

```shell
$ vagrant redir config [<name>]
```



### down 

Shut down redir processes used for port forwarding for VMs.
Same process vagrant starts on 'vagrant halt' command.

```shell
$ vagrant redir down
```
or for particular VM:

```shell
$ vagrant redir down [<name>]
```



### kill 

Kill redir processes used for port forwarding for VMs.
This is usefull when lxc contaner was stopped not by 'vagrant halt' command and redir processes are still running.

```shell
$ vagrant redir kill
```

or for particular VM:

```shell
$ vagrant redir kill [<name>]
```



### pids

Show stored redir pids and appropriate processes states
This is helpful to diagnose are all redir processes running or some of them are not running.

```shell
$ vagrant redir pids
```

will show:

```shell
List of stored redir's pids of VM 'xdg':
 pid: 16458; host_port: 8901; is_system_port: false; is_running: false
 pid: 16472; host_port: 8908; is_system_port: false; is_running: false
 pid: 16486; host_port: 8902; is_system_port: false; is_running: false
 pid: 16444; host_port: 8900; is_system_port: false; is_running: false

List of stored redir's pids of VM 'db1':
 pid: 16519; host_port: 9000; is_system_port: false; is_running: false
 pid: 16547; host_port: 9080; is_system_port: false; is_running: false
 pid: 16533; host_port: 9001; is_system_port: false; is_running: false
 pid: 16561; host_port: 9022; is_system_port: false; is_running: false
```

or for particular VM:

```shell
$ vagrant redir pids [<name>]
```



### ps

Show pids of running redir processes grepped by VM's public IP

```shell
$ vagrant redir ps
```

will show: 

```shell
List of running redir's pids for VM 'xdg' grepped by public IP:
 pid: 12637; host_port: 8900; is_system_port: false
 pid: 12651; host_port: 8901; is_system_port: false
 pid: 12665; host_port: 8908; is_system_port: false
 pid: 12679; host_port: 8902; is_system_port: false

List of running redir's pids for VM 'db1' grepped by public IP:
 pid: 12712; host_port: 9000; is_system_port: false
 pid: 12726; host_port: 9001; is_system_port: false
 pid: 12740; host_port: 9080; is_system_port: false
 pid: 12754; host_port: 9022; is_system_port: false
```

or for particular VM:

```shell
$ vagrant redir ps [<name>]
```




### status

Show list of running redir processes by stored pids.
This command cleans up inactive stored pids and shows only running ones. 

```shell
$ vagrant redir status
```

will show:

```shell
List of running redir processes for VM 'xdb' by stored pids:
 pid: 22351; host_port: 8901; is_system_port: false
 pid: 22365; host_port: 8908; is_system_port: false
 pid: 22379; host_port: 8902; is_system_port: false
 pid: 22337; host_port: 8900; is_system_port: false

List of running redir processes for VM 'db' by stored pids:
 pid: 22412; host_port: 9000; is_system_port: false
 pid: 22440; host_port: 9080; is_system_port: false
 pid: 22426; host_port: 9001; is_system_port: false
 pid: 22454; host_port: 9022; is_system_port: false
```


or for particular VM:

```shell
$ vagrant redir status [<name>]
```



### up

Setup port forwarding for vm(s).
Same process vagrant starts on 'vagrant up' command.

```shell
$ vagrant redir up
```


or for particular VM:

```shell
$ vagrant redir up [<name>]
```




## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/st02tkh/vagrant-redir. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vagrant::Redir project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/vagrant-redir/blob/master/CODE_OF_CONDUCT.md).
