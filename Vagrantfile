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

  (0...(n = cluster ? 3 : 1)).each do |i|
    hostname = "vagrant#{n > 1 ? (i + 1) : ''}"
    config.vm.define hostname, primary: (i == 0) do |host|
      host.vm.provider "docker" do |docker|
        # Build the image from the given Dockerfile in the current directory.
        if !(ansible_extra_vars["image"] || "").empty?
          docker.image = ansible_extra_vars["image"]
        else
          if !(ansible_extra_vars["dockerfile"] || "").empty?
            docker.dockerfile = ansible_extra_vars["dockerfile"]
          end
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
