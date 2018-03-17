#!/bin/bash
# AUTHOR: Phil Porada - philporada@gmail.com
# WHAT: This script generates an Ansible boilerplate....faster than light....
#       not really, but an ansible is superluminal communication.

BLD=$(tput bold)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
RST=$(tput sgr0)

COUNT=0
for i in ansible git ruby gem bundler vagrant; do
	command -v $i > /dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		printf "$BLD$RED-) You are missing a required tool: $i$RST\n"
		COUNT=$COUNT+1
	fi
done

if [ $COUNT -ne 0 ]; then
	exit 1
fi


usage() {
    printf "${BLD}Usage:$RST\n\n"
    printf "    ./$(basename $0)\n"
    printf "\n"
}

if [ ! -z $1 ]; then
	if [ $1 == '-h' ]; then
    	usage
		exit 0
	fi
fi

get_vars() {
	ANSIBLE_VERSION="$(ansible --version | head -n1 | awk '{print $2}' | awk -F. '{print $1 "." $2}')"
}


get_user_data() {
	ANSWER=n
	while [ $ANSWER == 'n' -o $ANSWER == 'N' ]; do
		printf "$BLD$GRN+) Name of the ansible role? Example:$RST$BLD /home/phil/ansible-role-httpd $BLD${GRN}or$RST$BLD ansible-role-nomad-jobs $BLD$GRN[ENTER]$RST\n"
		read ROLE_NAME
		printf "$BLD$GRN+) What software license do you want to use? Example:$RST$BLD MIT $BLD${GRN}or$RST$BLD GPL 3.0 $BLD$GRN[ENTER]$RST\n"
		read LICENSE
		printf "$BLD$GRN+) Is this correct? [Y/n] [ENTER]$RST\n"
		read ANSWER
	done
    BARE_ROLE_NAME="$(echo "${ROLE_NAME##*/}")"
}

create_boilerplate() {
printf "$BLD$GRN+) Creating folder$RST$BLD "${ROLE_NAME}"$RST\n"
mkdir -p "${ROLE_NAME}"/{defaults,tasks,meta,files,templates,handlers,test}
mkdir -p "${ROLE_NAME}"/test/integration/default/bats
git init "${ROLE_NAME}"

cat <<- PLAYBOOK >  "${ROLE_NAME}"/test/integration/default/default.yml
---
- hosts: test-kitchen
  vars:
  roles:
    - ${BARE_ROLE_NAME}
PLAYBOOK

cat <<- "TEST" > "${ROLE_NAME}"/test/integration/default/bats/01_test.bats
#!/usr/bin/env bats

@test "Ensure wget is installed" {
    run rpm -q wget
    [ "$status" -eq 0 ]
}
TEST

cat <<- "IDEMPOTENCE" > "${ROLE_NAME}"/test/integration/default/bats/99_idempotence.bats
#!/usr/bin/env bats

@test "Idempotence test - the second run should change nothing" {
    run bash -c "ansible-playbook -i /tmp/kitchen/hosts /tmp/kitchen/default.yml -c local | grep -q 'changed=0.*failed=0' && exit 0 || exit 1"
    [ "$status" -eq 0 ]
}
IDEMPOTENCE

cat <<- VAGRANT > "${ROLE_NAME}"/.vagrant.rb
Vagrant.configure(2) do |config|
  config.vm.provision "shell", inline: <<-SHELL
     sudo yum install -y epel-release git vim telnet net-tools
     sudo yum update -y epel-release
     sudo yum install -y ansible
  SHELL
end
VAGRANT

cat <<- KITCHEN > "${ROLE_NAME}"/.kitchen.yml
---
driver:
  name: vagrant
  use_sudo: false
  forward_agent: true

provisioner:
  hosts: test-kitchen
  name: ansible_playbook
  require_ansible_repo: true
  ansible_yum_repo: epel
  require_ansible_omnibus: false
  ansible_verbosity: 2
  ansible_verbose: true
  ansible_diff: true
  require_chef_for_busser: true
  update_package_repos: false

platforms:
  - name: centos-7
    driver:
      box: centos/7
      provision: true
      vagrantfiles:
        - .vagrant.rb

suites:
  - name: default
KITCHEN

cat <<- IGNORE > "${ROLE_NAME}"/.gitignore
.ansible/
.vagrant/
.kitchen/
IGNORE

cat <<- GEMFILE > "${ROLE_NAME}"/Gemfile
source "https://rubygems.org"

gem "test-kitchen"
gem "kitchen-vagrant"
gem "kitchen-ansible"
gem "busser-bats"
GEMFILE

cat <<- GEMLOCK > "${ROLE_NAME}"/Gemfile.lock
GEM
  remote: https://rubygems.org/
  specs:
    artifactory (2.5.1)
    busser (0.7.1)
      thor (<= 0.19.0)
    busser-bats (0.3.0)
      busser
    kitchen-ansible (0.45.7)
      net-ssh (~> 3.0)
      test-kitchen (~> 1.4)
    kitchen-vagrant (0.21.1)
      test-kitchen (~> 1.4)
    mixlib-install (2.1.9)
      artifactory
      mixlib-shellout
      mixlib-versioning
      thor
    mixlib-shellout (2.2.7)
    mixlib-versioning (1.1.0)
    net-scp (1.2.1)
      net-ssh (>= 2.6.5)
    net-ssh (3.2.0)
    net-ssh-gateway (1.2.0)
      net-ssh (>= 2.6.5)
    safe_yaml (1.0.4)
    test-kitchen (1.14.2)
      mixlib-install (>= 1.2, < 3.0)
      mixlib-shellout (>= 1.2, < 3.0)
      net-scp (~> 1.1)
      net-ssh (>= 2.9, < 4.0)
      net-ssh-gateway (~> 1.2.0)
      safe_yaml (~> 1.0)
      thor (~> 0.18)
    thor (0.19.0)

PLATFORMS
  ruby

DEPENDENCIES
  busser-bats
  kitchen-ansible
  kitchen-vagrant
  test-kitchen

BUNDLED WITH
   1.12.5
GEMLOCK

cat <<- DEFAULTS > "${ROLE_NAME}"/defaults/main.yml
---

DEFAULTS

cat <<- HANDLERS > "${ROLE_NAME}"/handlers/main.yml
---

HANDLERS

cat <<- MAIN > "${ROLE_NAME}"/tasks/main.yml
---
- include: install.yml

MAIN

cat <<- INSTALL > "${ROLE_NAME}"/tasks/install.yml
---

INSTALL

cat <<- META > "${ROLE_NAME}"/meta/main.yml
---
galaxy_info:
  author: Joël Weber - joel.weber@live.nl
  description: ${BARE_ROLE_NAME}
  company: Some Company
  min_ansible_version: ${ANSIBLE_VERSION}
  license: ${LICENSE}
  platforms:
    - name: EL
      versions:
        - 7

dependencies: []
META

cat <<- README > "${ROLE_NAME}"/README.md
# Ansible Role: ${BARE_ROLE_NAME}
[![License](https://img.shields.io/badge/license-${LICENSE}-brightgreen.svg)](LICENSE)

This role does XYZ. This is a boilerplate. Fill me out.

- - - -
# Role Variables

This var does XYZ

    var_name: "default value"

This var does ABC

    some_other_var: "default value"

- - - -
# Example Playbook

        ---
        - hosts: localhost
          connection: local
          become: true
          become_method: sudo
          roles:
            - ${BARE_ROLE_NAME}

- - - -
# How to hack away at this role
Before submitting a PR, please create a test and run it through test-kitchen. You will need to have at least Ruby 2.x, probably through [rbenv](https://github.com/rbenv/rbenv), and [Bundler](https://bundler.io/).

Set up test-kitchen dependencies

        bundle install
        bundle update

Test-kitchen needs our github ssh key so it can pull code from github on our behalf.

        ssh-add -D
        ssh-add -k ~/GITHUB_KEYNAME
        ssh-add -L
        bundle exec kitchen create
        bundle exec kitchen converge
        bundle exec kitchen verify
        bundle exec kitchen destroy

- - - -
# Theme Music
[The Slackers - Same Everyday](https://www.youtube.com/watch?v=Qy_2OqTvW34)

- - - -
# License and Author Information
${LICENSE}

(c) $(date +%Y) Joël Weber - joel.weber@live.nl
README
}

main() {
	get_vars
	get_user_data
	create_boilerplate
}

main
