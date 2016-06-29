#!/usr/bin/env bash

HOSTNAME=$(grep -oP '\[.*\]+' /vagrant/ansible/inventories/dev | cut -c2- | rev | cut -c2- | rev)

# first install
if [ ! -f /home/vagrant/.installed ]; then
    # Update repositories
    sudo aptitude update

    # Install required packages
    sudo aptitude install -y software-properties-common python-pip libxml2-dev python-dev sshpass git curl build-essential libssl-dev libffi-dev
    sudo pip install --upgrade markupsafe jinja2 ansible

    # Setup ansible for local use
    sudo mkdir -p /etc/ansible/
    sudo cp /vagrant/ansible/inventories/dev /etc/ansible/hosts -f
    sudo chmod 666 /etc/ansible/hosts
    sudo cat /vagrant/ansible/files/authorized_keys >> /home/vagrant/.ssh/authorized_keys

    # Add ansible.cfg to pick up roles path.
    #"{ echo '[defaults]'; echo 'roles_path = ../'; } >> ansible.cfg"

    # change working dir
    cd /vagrant/ansible

    # Install required ansible roles
    sudo ansible-galaxy install -r /vagrant/ansible/requirements.yml --ignore-errors --force

    date > /home/vagrant/.installed
fi

# change working dir
cd /vagrant/ansible
ansible --version

echo "Start ansible playbook"
echo "ansible-playbook /vagrant/ansible/playbook.yml -e hostname=${HOSTNAME} --connection=local --become"
ansible-playbook /vagrant/ansible/playbook.yml -e hostname=${HOSTNAME} --connection=local --become
echo "provisioning finished in ${UPTIME} seconds"
