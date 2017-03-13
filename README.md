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
- Even if `nomadconfig_src_dir` isn't defined, `nomad_config_remote_dir` has a default config file generated from [./templates/nomad_common.json.j2](./templates/nomad_common.json.j2).
  The variables related to this default config file are as follows.
  If you want to overwrite these values, please also check https://www.nomadproject.io/docs/agent/configuration/index.html.

|name|description|type|default|
|---|---|---|---|
|nomad_default_config_data_dir|In Nomad configuration, it collesponds to [data_dir](https://www.nomadproject.io/docs/agent/configuration/index.html#data_dir).|str|/tmp/nomad|
|nomad_default_config_bind_addr|In Nomad configuration, it collesponds to [bind_addr](https://www.nomadproject.io/docs/agent/configuration/index.html#bind_addr).|str|0.0.0.0|
|nomad_default_config_datacenter|In Nomad configuration, it collesponds to [datacenter](https://www.nomadproject.io/docs/agent/configuration/index.html#datacenter).|str|dc1|
|nomad_default_config_advertise|In Nomad configuration, it collesponds to [advertise](https://www.nomadproject.io/docs/agent/configuration/index.html#advertise). <br>In this role, Same value is set as `advertise.http`, `advertise.rpc`, and `advertise.serf`.|str|It isn't defined in default.|
|nomad_default_config_consul_address|In Nomad configuration, it collesponds to [consul.address](https://www.nomadproject.io/docs/agent/configuration/consul.html#address).|str|It isn't defined in default.|
|nomad_default_config_server_bootstrap_expect|In Nomad configuration, it collesponds to [server.bootstrap_expect](https://www.nomadproject.io/docs/agent/configuration/server.html#bootstrap_expect).|str|It isn't defined in default.|
|nomad_default_config_client_servers|In Nomad configuration, it collesponds to [client.servers](https://www.nomadproject.io/docs/agent/configuration/client.html#servers). <br>But you can add only 1 server in default config.|str|It isn't defined in default.|

### Only not-container

These values are related to daemon script of Nomad, and these are meaningful on not-container environment.
Container doesn't use daemon script because main program in container must run on foreground.

|name|description|type|default|
|---|---|---|---|
|nomad_daemon_log_dir|Directory including log files of daemon(named `stdout.log` and `stderr.log`). <br>It's owned by `nomad_owner`.|str|/var/log/nomad|
|nomad_daemon_pid_dir|Directory including PID file of daemon(named `nomad.pid`). <br>It's owned by `nomad_owner`.|str|/var/run/nomad|
|nomad_daemon_script_dir|Directory including daemon script(named `daemons.py`). <br>It's owned by `nomad_owner`.|str|/opt/nomad|

- It's better to use dedicated directories for `nomad_daemon_log_dir` and `nomad_daemon_pid_dir`.
  If you use existing directores(ex. `/var/log`, `/var/run`), this role mayn't work well.

### Only Linux

These values are meaningful only on Linux.

|name|description|type|default|
|---|---|---|---|
|nomad_download_url|Download URL of Nomad archive.|str|https://releases.hashicorp.com/nomad/0.5.4/nomad_0.5.4_linux_amd64.zip|
|nomad_sha256|SHA256 signature of Nomad archive.|str|ed9eb471b9f5bab729cfa402db5aa56e1d935c328ac48327267e0ea53568d5c2|
|nomad_download_tmppath|File path downloaded Nomad archive is put temporary.|str|/tmp/nomad.zip|
|nomad_bin_dir|Directory path Nomad binary is put. The path of Nomad binary is `{{ nomad_bin_dir }}/nomad`.|str|/usr/local/bin|

- `nomad_bin_dir` should exist in `PATH` environment variable. Or the daemon script can't work well.
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
$ ansible-playbook tests/setup_cluster.yml -i tests/inventory -l localhost
$ vagrant up
$ ansible-playbook tests/test.yml -i tests/inventory -l cluster
$ ansible-playbook tests/setup_cluster.yml -i tests/inventory -l cluster
$ ansible-playbook tests/run_cluster.yml -i tests/inventory -l cluster
$ ansible-playbook tests/run_nomadjob.yml -i tests/inventory -l cluster
#
# Wait a minute. Submitting jobs takes a few time.
#
$ bundle install --path vendor/bundle
$ bundle exec rake spec:server
$ bundle exec rake spec:client
```

License
-------

MIT
