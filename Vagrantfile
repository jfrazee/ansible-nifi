# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'
require 'getoptlong'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Enable reading variables from .env.
  config.env.enable

  # Load .env.yml, maybe it's a cluster, maybe it's Maybelline.
  ansible_extra_vars, cluster = {}, false
  if File.exist?(".env.yml")
    ansible_extra_vars = YAML.load(open(".env.yml")).to_h
    cluster = ansible_extra_vars.fetch("nifi_cluster", false)
  end

  # Add option to dump environment with `vagrant --dump-vars`
  opts = GetoptLong.new([ '--dump-vars', GetoptLong::OPTIONAL_ARGUMENT])
  opts.ordering=(GetoptLong::REQUIRE_ORDER)
  opts.each do |opt, arg|
    case opt
    when '--dump-vars'
      puts JSON.pretty_generate({
        ENV: ENV.to_h,
        ansible_extra_vars: ansible_extra_vars
      })
      exit 1
    end
  end

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  (0...(n = cluster ? 3 : 1)).each do |i|
    hostname = "vagrant#{n > 1 ? (i + 1) : ''}"
    config.vm.define hostname, primary: (i == 0) do |host|
      host.vm.provider "docker" do |docker|
        # Build the image from the given Dockerfile in the current directory.
        case
        when !(ansible_extra_vars["image"] || "").empty?
          docker.image = ansible_extra_vars["image"]
        when !(ansible_extra_vars["dockerfile"] || "").empty?
          docker.dockerfile = ansible_extra_vars["dockerfile"]
          docker.build_dir = "."
        else
          docker.build_dir = "."
        end

        # Need this on some host OS's to set kernel params.
        docker.create_args = ["--cap-add=SYS_ADMIN"]

        # Expose SSH on the containers.
        docker.has_ssh = true
        docker.remains_running = true

        # Expose nifi and zookeeper on the containers.
        docker.ports = ["#{9990+i}:8080", "#{9443+i}:9443", "#{2181+i}:2181", "#{2281+i}:2281"]
      end

      host.vm.provision "ansible" do |ansible|
        ansible.limit = "all"
        ansible.playbook = "tests/test.yml"
        ansible.become = true
        ansible.raw_arguments = ["-e", "role_name=ansible-nifi"]

        if File.exist?(".env.yml") && !(ansible_extra_vars || {}).empty?
          ansible.extra_vars = ansible_extra_vars.reject { |k|
            ["dockerfile", "image"].include?(k)
          }
        end
      end if i == n - 1
    end
  end

end
