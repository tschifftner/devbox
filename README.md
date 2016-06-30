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

### 2. Clone repository

```
git clone git@github.com:tschifftner/devbox.git
```

### 3. Start vagrant
```
cd devbox 
vagrant up
```

The box will be downloaded (on first start) and started. Provisioning 
will be done automatically after startup.
 
### 4. Reprovision / Troubles

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
 
Add new file ```ansible/group_vars/all/project.yml``` with the following
content:

```
---
project_user: vagrant

devbox_projects:
  - name: demo
    root: pub/
    environment: devbox
    server_alias: dev2.local
    databases: ['dev2_local', 'dev3_local']
    #remove: true

  - name: demo2
    environment: devbox
    server_alias: devbox2.local
    databases: ['devbox2']
    remove: true

  - name: magento2demo
    type: magento2
    environment: devbox
    server_alias: magento2demo.local
    databases: ['magento2demo']
    awscli:
      - profilename: 'magento2demo'
        aws_access_key_id: 'XXXXXXXXXX'
        aws_secret_access_key: 'XXXXXXXXXXXXXXXXXX'
        region: 'eu-central-1'

  - name: demo_project
    type: magento
    environment: devbox
    server_alias: demo_project.local
    databases: ['demo_project']
    deploy_scripts: 'git@bitbucket.org:ambimax/magento-deployscripts.git'
    awscli:
      - profilename: 'demo_project'
        aws_access_key_id: 'XXXXXXXXXX'
        aws_secret_access_key: 'XXXXXXXXXXXXXXXXXXXX'
        region: 'eu-central-1'
    motd: |
      Demo Project
      ====
      Update systemstorage
      aws --profile demo_project s3 cp --recursive s3://bucket/demo_project/backup/production /home/projectstorage/demo_project/backup/production

      Install
      /home/projectstorage/demo_project/bin/deploy/deploy.sh -d -e devbox -a demo_project -r s3://bucket/demo_project/builds/demo_project.de.tar.gz -t /var/www/demo_project/devbox
```

_File can be named differently but will not be in .gitignore_

Run ```/vagrant/ansible/provision.sh``` to create all projects

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


## License

MIT / BSD

## Author Information

 - Tobias Schifftner, @tschifftner