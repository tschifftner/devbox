#!/usr/bin/env bash

echo "Update projects"
ansible-playbook /vagrant/ansible/playbook.yml --connection=local --become --tags projects
