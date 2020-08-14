# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Enable reading variables from .env.
  config.env.enable

  # Load .env.yml, maybe it's a cluster, maybe it's Maybelline.
  env_yml, ansible_extra_vars = File.expand_path(".env.yml", __dir__), {}
  if File.exist?(env_yml)
    ansible_extra_vars = YAML.load(open(env_yml)).to_h
  end

  n = ansible_extra_vars.fetch("nifi_cluster", false) ? 3 : 1
  (0...n).each do |i|
    hostname = n > 1 ? "vagrant#{i+1}" : "vagrant"
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

        # Expose NiFi and ZooKeeper ports on the containers.
        docker.ports = [8080, 8443, 9443, 10443, 11443, 6342, 2181, 2281].map { |p| "#{p+i}:#{p}" }.to_a
      end

      host.vm.provision "ansible" do |ansible|
        ansible.limit = "all"
        ansible.playbook = "tests/test.yml"
        ansible.become = true

        # Set the playbook and add any other extra arguments from .env.yml.
        extra_raw_arguments = ["-e", "role_name=ansible-nifi"]
        if !(ansible_extra_vars["extra_raw_arguments"] || []).empty?
          extra_raw_arguments +=
            ansible_extra_vars["extra_raw_arguments"].split(/\s+/)
        end

        ansible.raw_arguments = extra_raw_arguments.to_a

        # Get playbook vars from .env.yml.
        if File.exist?(env_yml) && !(ansible_extra_vars || {}).empty?
          ansible.extra_vars = ansible_extra_vars.reject { |k|
            ["extra_raw_arguments", "dockerfile", "image"].include?(k)
          }
        end
      end if i == n - 1
    end
  end

end
