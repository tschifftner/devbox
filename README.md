# ambimax® devbox

[![Build Status](https://travis-ci.org/tschifftner/devbox.svg)](https://travis-ci.org/tschifftner/devbox)

This vagrant box is heavily inspired by @fbrnc unibox and is supposed
to help developing on a modern virtual server

### Installed software

OS: Debian Jessie 64bit

- awscli
- composer
- mariadb
- motd
- modman
- n98-magerun
- n98-magerun2
- nginx
- php5-fpm
- redis
- samba

## Provisioning

### Automatic fetching of ansible roles
Provisioning is done by ansible roles that are installed by 
ansible-galaxy in requirements.yml

### Add ansible roles to install process
Either add the name of the role to an existing file (all.yml or webserver.yml)
or include your own yml file.

### Create samba share on windows client
```
net use B: \\192.168.33.99\www /persistent:no /user:vagrant vagrant
```

# Installation

### 1. Install required software

- [Vagrant 1.8+](http://vagrantup.com)
- [VirtualBox 5.0](https://www.virtualbox.org/)

### 2. Install vagrant plugin

```
vagrant plugin install vagrant-vbguest
```

### 3. Clone repository

```
git clone git@github.com:tschifftner/devbox.git
```

### 4. Start vagrant
```
cd devbox 
vagrant up
```

The box will be downloaded (on first start) and started. Provisioning 
will be done automatically after startup.
 
### 5. Reprovision / Troubles

If the box did not provision properly or you want to rerun the
provisioning script:

```
vagrant ssh
/vagrant/ansible/provision.sh
```

### Update provisioning scripts

To update to the latest ansible roles from ansible galaxy use:

```
vagrant ssh
/vagrant/ansible/update.sh
```

## Vhost management

### Create and manage vhosts

Add every project to a own file:

```
ansible/group_vars/devbox/demo.yml
ansible/group_vars/devbox/demo2.yml
...
ansible/group_vars/devbox/any_other_repo.yml
```

```
# file ansible/group_vars/devbox/example.yml
demo_project:
    name: demo
    root: pub/
    environment: devbox
    server_alias: dev2.local
    databases: ['dev2_local', 'dev3_local']
    #remove: true
    awscli:
      - profilename: 'demo'
        aws_access_key_id: 'XXXXXXXXXX'
        aws_secret_access_key: 'XXXXXXXXXXXXXXXXXX'
        region: 'eu-central-1'
    helper:
      - name: fullsync
        info: 'Synchronizes full media in projectstorage folder with aws s3'
        command: 'aws --profile demo s3 cp --recursive s3://bucket/demo/backup/production /home/projectstorage/demo/backup/production'
    
      - name: fastsync
        info: 'Synchronises database but only files timestamp file'
        command: >
          aws --profile demo s3 cp --recursive s3://bucket/demo/backup/production/database /home/projectstorage/demo/backup/production/database &&
          aws --profile demo s3 cp s3://bucket/demo/backup/production/files/created.txt /home/projectstorage/demo/backup/production/files/created.txt
    
      - name: reset
        info: 'Imports latest database and synchronises media files with projectstorage'
        command:  '/home/projectstorage/demo/bin/deploy/project_reset.sh -p /var/www/demo/devbox/releases/current/htdocs/ -s /home/projectstorage/demo/backup/production'
    
      - name: cleanup
        info: 'Removes all releases except for current'
        command: '/home/projectstorage/demo/bin/deploy/cleanup.sh -r /var/www/demo/devbox/releases -n 1'
    
      - name: install
        info: 'deploys full project including database import and media synchronisation'
        command: '/home/projectstorage/demo/bin/deploy/deploy.sh -d -e devbox -a demo -r s3://bucket/demo/builds/demo.de.tar.gz -t /var/www/demo/devbox'
```

```
# file ansible/group_vars/devbox/demo2.yml
demo2_project:
    name: demo2
    type: magento
    environment: devbox
    server_alias: demo2.local
    databases: ['demo2']
    deploy_scripts: 'git@bitbucket.org:ambimax/magento-deployscripts.git'
    awscli:
      - profilename: 'demo2'
        aws_access_key_id: 'XXXXXXXXXX'
        aws_secret_access_key: 'XXXXXXXXXXXXXXXXXXXX'
        region: 'eu-central-1'
    motd: |
      Demo Project
      ====
      Update systemstorage
      aws --profile demo2 s3 cp --recursive s3://bucket/demo2/backup/production /home/projectstorage/demo2/backup/production

      Install
      /home/projectstorage/demo2/bin/deploy/deploy.sh -d -e devbox -a demo2 -r s3://bucket/demo2/builds/demo2.de.tar.gz -t /var/www/demo2/devbox
```

### Add the projects you need to ```ansible/group_vars/devbox/_projects.yml```:

```
devbox_projects:
  - '{{ demo_project }}'
  - '{{ demo2_project }}'
#  - '{{ any_other_repo }}'
```

Run ```/vagrant/ansible/update-projects.sh``` to create all projects

## Helper scripts

Helper scripts are generated and can be called by entering the name of the project.
For example ```demo```
Please define available helpers like so:

```
    helper:
      - name: fullsync
        info: 'Synchronizes full media in projectstorage folder with aws s3'
        command: 'aws --profile demo s3 cp --recursive s3://bucket/demo/backup/production /home/projectstorage/demo/backup/production'

      - name: fastsync
        info: 'Synchronises database but only files timestamp file'
        command: >
          aws --profile demo s3 cp --recursive s3://bucket/demo/backup/production/database /home/projectstorage/demo/backup/production/database &&
          aws --profile demo s3 cp s3://bucket/demo/backup/production/files/created.txt /home/projectstorage/demo/backup/production/files/created.txt

      - name: reset
        info: 'Imports latest database and synchronises media files with projectstorage'
        command:  '/home/projectstorage/demo/bin/deploy/project_reset.sh -p /var/www/demo/devbox/releases/current/htdocs/ -s /home/projectstorage/demo/backup/production'

      - name: cleanup
        info: 'Removes all releases except for current'
        command: '/home/projectstorage/demo/bin/deploy/cleanup.sh -r /var/www/demo/devbox/releases -n 1'

      - name: install
        info: 'deploys full project including database import and media synchronisation'
        command: '/home/projectstorage/demo/bin/deploy/deploy.sh -d -e devbox -a demo -r s3://bucket/demo/builds/demo.de.tar.gz -t /var/www/demo/devbox'
```

To update helper scripts only:

```
ansible-playbook /vagrant/ansible/playbook.yml --connection=local --become --tags devbox-helper
```

## Magento 2 Installation

```
composer create-project magento/project-community-edition <installation dir>
```

### set permissions for installation
```
chmod -R 777 var pub/media/ pub/static app/etc
```


### Magento 2 SampleData

[https://github.com/magento/magento2-sample-data/tree/develop/app/code/Magento](https://github.com/magento/magento2-sample-data/tree/develop/app/code/Magento)

### Create admin user

```
php bin/magento admin:user:create --admin-user=admin --admin-password=test123 --admin-firstname=Test --admin-lastname=Admin --admin-email=admin@example.org
```

Credentials:
/root/.composer/auth.json

## Project structures

### Default
All projects belong into ```/var/www/{{project.name}}/{{project.environment}}/releases/current``` (symlink can be used!)

To have a custom public root folder, please specify project.root for this like

```
devbox_projects:
  - name: demo
    root: pub/
    environment: devbox
    server_alias: dev2.local
    databases: ['db']
```

### Magento 1

_If your Magento project does not use composer and modman in our way, please use normal project type._

Our Magento projects have the following file structure:
```
config/
    settings.csv
htdocs/
    app/
    dev/
    downloader/
    ...
    skin/
    var/
    index.php
tools/
    install.sh
    composer.phar
```    

Therefore nginx and php root is /htdocs (!)

### Magento 2

Magento 2 is handled by composer and should go directly into ```/var/www/{{project.name}}/{{project.environment}}/releases/current```

## Add additional HDD

```
sudo fdisk -l
sudo fdisk /dev/sdb
p) to print partitions
n) to start new partition
p) to print partitions
w) to write partition to disk
q) to quit fdisk

sudo fdisk -l
sudo mkfs.ext4 /dev/sdb1
```

### Mount on startup

Create mount folder
```
sudo mkdir /www
```

Add mount options to ```/etc/fstab```
```
/dev/sdb1 /www ext4 defaults,relatime 1 1
```

## License

[MIT License](http://choosealicense.com/licenses/mit/)

## Author Information

 - Tobias Schifftner, @tschifftner