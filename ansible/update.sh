#!/usr/bin/env bash

echo "Start ansible playbook"
echo "ansible-playbook /vagrant/ansible/playbook.yml --connection=local --sudo --tags devbox"
ansible-playbook /vagrant/ansible/playbook.yml --connection=local --become
echo "provisioning finished in $UPTIME seconds"
