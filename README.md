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
|nomad_config_remote_dir|Directory including Nomad config files on remote. In almost cases, this value will be passed with `-config` option of Nomad.|str|/etc/nomad.d|
|nomad_owner|User of `nomad_config_remote_dir` directory and Nomad config files under it.|str|root|
|nomad_group|Group of `nomad_config_remote_dir` directory and Nomad config files under it.|str|root|

- The value of `nomad_config_src_dir` is used as 'src' attribute of Ansible copy module. Thus, whether this value ends with '/' affects the behavior. (Ref. http://docs.ansible.com/ansible/copy_module.html)
- The values of `nomad_config_remote_dir`, `nomad_owner`, and `nomad_group` are ignored when `nomad_config_src_dir` isn't defined.

### Only Debian

If you want to overwrite values, please also check https://www.nomadproject.io/downloads.html.

|name|description|type|default|
|---|---|---|---|
|nomad_download_url|Download URL of Nomad archive. <br>If you want to overwrite values, please also check https://www.nomadproject.io/downloads.html.|str|https://releases.hashicorp.com/nomad/0.5.0/nomad_0.5.0_linux_amd64.zip|
|nomad_sha256|SHA256 signature of Nomad archive. <br>If you want to overwrite values, please also check https://www.nomadproject.io/downloads.html.|str|7f7b9af2b1ff3e2c6b837b6e95968415237bb304e1e82802bc42abf6f8645a43|
|nomad_download_tmppath|File path downloaded Nomad archive is put temporary.|str|/tmp/nomad.zip|
|nomad_bin_dir|Directory path Nomad binary is put|str|/usr/local/bin|

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

License
-------

MIT
