#!/usr/bin/env bash

# Install required ansible roles
sudo ansible-galaxy install -r /vagrant/ansible/requirements.yml --ignore-errors --force

echo "Start ansible playbook"
echo "ansible-playbook /vagrant/ansible/playbook.yml --connection=local --sudo --tags devbox"
ansible-playbook /vagrant/ansible/playbook.yml --connection=local --become
echo "provisioning finished in $UPTIME seconds"
