#! /bin/bash

# Install Ansible
sudo yum install -y epel-release
sudo yum install -y ansible
# Verify installation
ansible --version