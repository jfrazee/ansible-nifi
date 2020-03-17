# ansible-nifi

An [Ansible](https://www.ansible.com) role for [Apache NiFi](http://nifi.apache.org)

## Overview

This is an Ansible role for installing and running Apache NiFi, either standalone or as a cluster. It also installs dependencies such as Java, and ZooKeeper if needed. Additionally, to make development easy it includes [Vagrant](https://www.vagrantup.com) and [Docker](https://www.docker.com/get-started) files which can be used to test the role and run NiFi standalone instances or clusters.

## Requirements

The role assumes all Ansible requirements are met on the managed nodes, including sshd, sftp-server, and python. The role and Dockerfiles will also ensure that the following are installed to ensure that all of the included tasks can be excuted:

* iproute(2)
* bash
* python3
* GNU tar
* GNU grep
* gzip
* unzip
* supervisord (Docker only)

## Role Variables

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

## Example Playbook

You can use ansible-nifi in your playbooks by including `nifi` in the list of roles.

```
- hosts: all
  roles:
     - { role: nifi }
```

## Using for Development

### Basic Usage

To get started developing ansible-nifi or using it for NiFi development, first install Ansible, Docker, and Vagrant:

```console
$ brew install ansible
$ brew cask install docker
$ brew cask install vagrant
$ vagrant plugin install vagrant-env
```

Then create an `.env.yml` such as:

```yaml
---
package_base_url: /vagrant/files
nifi_version: 1.11.3
nifi_cluster: yes
zookeeper_install: no
zookeeper_version: 3.5.7
dockerfile: Dockerfile.centos
```

This will tell Vagrant to create a containerized NiFi cluster, with a locally installed ZooKeeper, using binaries from `./files` (instead of fetching from the internet). This makes it possible, for example, to use already downloaded binaries as well as packages built from source instead of fetching the binaries from Apache Software Foundation (ASF) mirrors.

Finally:

```console
$ vagrant up
```

### Advanced Usage

#### Configuration

For usage in a playbook, the role can be configured using any variable provided in `./defaults/main.yml` (see above). Additionally, when using ansible-nifi with Vagrant, any valid role variable can be set in `./env.yml` and the Ansible shell environment can be set in `.env`. You can inspect these by running Vagrant with the `--dump-vars` option:

```console
$ vagrant --dump-vars
```

#### Docker

Vagrant is configured to use the Docker provider. A pre-built Docker image can be specified in `.env.yml` with the `image` variable. Otherwise the image will be built on `vagrant up` using either whatever `dockerfile` is set to in `.env.yml` or the current working directory `Dockerfile` (which links to `Dockerfile.alpine` by default).

The provided Dockerfiles are for development and use with Vagrant and *not* for production use. They do show, however, what the assumed dependencies are. The `Dockerfile.minimal` illustrates the minimum; other dependenices (e.g., Java) will get installed during the Ansible provisioning. That said, using containers with dependencies pre-installed will make the play run faster since it won't be downloading required packages from the internet.

You can build Docker images in the usual way:

```console
$ docker build -f Dockerfile.centos -t ansible-nifi/centos .
```

#### Supervisord

By default, supervisord is used for init-like process management if the install target is Docker. The `supervisorctl` command can be used to control NiFi, as well as ZooKeeper (if it's installed locally):

```console
$ vagrant docker-exec -- sudo supervisorctl status nifi:
==> vagrant: nifi                             RUNNING   pid 1239, uptime 5:31:49
==> vagrant: nifi:zookeeper                   RUNNING   pid 1238, uptime 5:31:49
```

Or:

```console
$ vagrant docker-exec -- sudo supervisorctl restart nifi:
==> vagrant: nifi:zookeeper: stopped
==> vagrant: nifi: stopped
==> vagrant: nifi:zookeeper: started
==> vagrant: nifi: started
```

Similar commands can be run using supervisord outside of Vagrant and Docker.

#### Package Location or Build from Source

The ansible-nifi role allows you to specify a `package_base_url` to fetch binaries from. This can be used in several ways:

1. Install disconnected from the internet by providing a directory path to the convenience binaries. This works either for local development using Vagrant or production use of the ansible-nifi role.
2. Install from the `/vagrant` mount so the binaries aren't fetched on every run of `vagrant up`.
3. Use the binary packages from a source build. These are generated from `mvn clean install -DskipTests` in `./nifi-assembly/target/nifi-<VERSION>-bin.zip`.

## Deployment

### Local Provisioning

```console
$ mkdir /etc/ansible/roles
$ git clone https://github.com/jfrazee/ansible-nifi.git /etc/ansible/roles/nifi
$ cat<<EOF > playbook.yml
---
- hosts: 127.0.0.1
  connection: local
  roles:
     - nifi
EOF
$ ansible-playbook --extra-vars '@env.yml' playbook.yml
```

## Limitations

The role does not currently provide any functionality for configuring TLS for either NiFi or ZooKeeper.

## License

Copyright &copy; 2017 Joey Frazee. ansible-nifi is released under the Apache License Version 2.0.
