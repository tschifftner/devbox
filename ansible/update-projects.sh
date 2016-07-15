#!/usr/bin/env bash

echo "Update projects"
ansible-playbook /vagrant/ansible/playbook.yml --connection=local --become --tags devbox,mariadb-databases,mariadb-users,nginx-vhosts,php5-fpm-pools,awscli-configure
