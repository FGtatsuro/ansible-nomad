ansible-nomad
====================================

[![Build Status](https://travis-ci.org/FGtatsuro/ansible-nomad.svg?branch=master)](https://travis-ci.org/FGtatsuro/ansible-nomad)

Ansible role for Nomad.

Requirements
------------

The dependencies on other softwares/librarys for this role.

- Debian
- OSX
  - Homebrew (>= 0.9.5)

Role Variables
--------------

The variables we can use in this role.

### Common

|name|description|type|default|
|---|---|---|---|
|nomad_config_src_dir|Directory including Nomad config files on local. Config files are copied to `nomad_config_remote_dir` directory on remote.|str|It isn't defined in default. No Nomad config file is copied to remote.|
|nomad_config_remote_dir|Directory including Nomad config files on remote. In almost cases, this value will be passed with `-config` option of Nomad. <br>It's owned by `nomad_owner`.|str|/etc/nomad.d|
|nomad_owner|User of components related to Nomad.|str|nomad|
|nomad_group|Group of components related to Nomad.|str|nomad|

- The value of `nomad_config_src_dir` is used as 'src' attribute of Ansible copy module. Thus, whether this value ends with '/' affects the behavior. (Ref. http://docs.ansible.com/ansible/copy_module.html)
- The values of `nomad_config_remote_dir`, `nomad_owner`, and `nomad_group` are ignored when `nomad_config_src_dir` isn't defined.

### Only Linux

These values are meaningful only on Linux.

|name|description|type|default|
|---|---|---|---|
|nomad_download_url|Download URL of Nomad archive.|str|https://releases.hashicorp.com/nomad/0.5.4/nomad_0.5.4_linux_amd64.zip|
|nomad_sha256|SHA256 signature of Nomad archive.|str|ed9eb471b9f5bab729cfa402db5aa56e1d935c328ac48327267e0ea53568d5c2|
|nomad_download_tmppath|File path downloaded Nomad archive is put temporary.|str|/tmp/nomad.zip|
|nomad_bin_dir|Directory path Nomad binary is put. The path of Nomad binary is `{{ nomad_bin_dir }}/nomad`.|str|/usr/local/bin|

- If you want to overwrite values, please also check https://www.nomadproject.io/downloads.html.

Role Dependencies
-----------------

The dependencies on other roles for this role.

- FGtatsuro.python-requirements

Example Playbook
----------------

    - hosts: all
      roles:
         - { role: FGtatsuro.nomad }

Test on local Docker host
-------------------------

This project run tests on Travis CI, but we can also run them on local Docker host.
Please check `install`, `before_script`, and `script` sections of `.travis.yml`.
We can use same steps of them for local Docker host.

Local requirements are as follows.

- Ansible (>= 2.0.0)
- Docker (>= 1.10.1)

Test on Vagrant VM
------------------

To confirm the behavior of Nomad cluster(server-client mode), we run tests on Vagrant VMs.

```
$ pip install ansible
$ ansible-galaxy install FGtatsuro.vagrant FGtatsuro.docker-toolbox
$ ansible-playbook tests/setup_clusterspec.yml -i tests/inventory -l localhost
$ vagrant up
$ ansible-playbook tests/test.yml -i tests/inventory -l cluster
$ ansible-playbook tests/setup_clusterspec.yml -i tests/inventory -l cluster
$ vagrant ssh server -c "sudo su -l nomad -c 'mkdir -p /tmp/nomad && nohup nomad agent -server -bootstrap-expect=1 -bind=192.168.50.4 -data-dir=/tmp/nomad -dc=dc1 &'"
$ vagrant ssh client -c "sudo su -l nomad -c 'mkdir -p /tmp/nomad && nohup nomad agent -client -join=192.168.50.4 -bind=192.168.50.5 -data-dir=/tmp/nomad -dc=dc1 -config=/etc/nomad.d &'"
$ vagrant ssh server -c "nomad init"
$ vagrant ssh server -c "nomad run -address=http://192.168.50.4:4646 example.nomad"
$ bundle install --path vendor/bundle
$ bundle exec rake spec:server
$ bundle exec rake spec:client
```

License
-------

MIT
