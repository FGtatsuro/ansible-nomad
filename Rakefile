require 'rake'
require 'rspec/core/rake_task'

task :spec    => 'spec:all'
task :default => :spec

namespace :spec do
  hosts = [
    {
      :name     =>  'localhost',
      :backend  =>  'exec',
      :nomad_config_remote_dir =>  '/Users/travis/nomad.d',
      :nomad_owner  =>  'travis',
      :nomad_group  =>  'staff',
      :nomad_advertise_interface  =>  'en0',
      # Consul doesn't run on CI, but I can check whether proper config is written in common setting file.
      :nomad_consul_address => '127.0.0.1:8400',
      :nomad_server  =>  'false',
      :nomad_client  =>  'false',
      :pattern  =>  'spec/nomad_spec.rb,spec/nomad_daemon_dev_spec.rb'
    },
    {
      :name     =>  'container',
      :backend  =>  'docker',
      :nomad_config_remote_dir =>  '/etc/nomad.d',
      :nomad_owner  =>  'nomad',
      :nomad_group  =>  'nomad',
      :pattern  =>  'spec/nomad_spec.rb'
    },
    {
      :name =>  'server',
      :backend  =>  'vagrant',
      :nomad_config_remote_dir =>  '/etc/nomad.d',
      :nomad_owner  =>  'nomad',
      :nomad_group  =>  'nomad',
      :nomad_server_addr  =>  '192.168.50.4',
      :nomad_client_addr  =>  '192.168.50.5',
      :nomad_advertise_config_addr =>  '192.168.50.4',
      :nomad_server  =>  'true',
      :nomad_bootstrap_expect => '1',
      :pattern  =>  'spec/nomad_spec.rb,spec/nomad_daemon_cluster_spec.rb'
    },
    {
      :name =>  'client',
      :backend  =>  'vagrant',
      :nomad_config_remote_dir =>  '/etc/nomad.d',
      :nomad_owner  =>  'nomad',
      :nomad_group  =>  'nomad',
      :nomad_server_addr  =>  '192.168.50.4',
      :nomad_client_addr  =>  '192.168.50.5',
      :nomad_advertise_config_addr =>  '192.168.50.5',
      :nomad_join_server  =>  '192.168.50.4',
      :nomad_client  =>  'true',
      :pattern  =>  'spec/nomad_spec.rb,spec/nomad_daemon_cluster_spec.rb'
    }
  ]
  if ENV['SPEC_TARGET'] then
    target = hosts.select{|h|  h[:name] == ENV['SPEC_TARGET']}
    hosts = target unless target.empty?
  end

  task :all     => hosts.map{|h|  "spec:#{h[:name]}"}
  task :default => :all

  hosts.each do |host|
    desc "Run serverspec tests to #{host[:name]}(backend=#{host[:backend]})"
    RSpec::Core::RakeTask.new(host[:name].to_sym) do |t|
      ENV['TARGET_HOST'] = host[:name]
      ENV['SPEC_TARGET_BACKEND'] = host[:backend]
      ENV['NOMAD_CONFIG_REMOTE_DIR'] = host[:nomad_config_remote_dir]
      ENV['NOMAD_OWNER'] = host[:nomad_owner]
      ENV['NOMAD_GROUP'] = host[:nomad_group]
      ENV['NOMAD_ADVERTISE_CONFIG_ADDR'] = host[:nomad_advertise_config_addr]
      ENV['NOMAD_ADVERTISE_ADDR'] = host[:nomad_advertise_config_addr]
      ENV['NOMAD_SERVER_ADDR'] = host[:nomad_server_addr]
      ENV['NOMAD_CLIENT_ADDR'] = host[:nomad_client_addr]
      ENV['NOMAD_SERVER'] = host[:nomad_server]
      ENV['NOMAD_CONSUL_ADDRESS'] = host[:nomad_consul_address]
      ENV['NOMAD_BOOTSTRAP_EXPECT'] = host[:nomad_bootstrap_expect]
      ENV['NOMAD_JOIN_SERVER'] = host[:nomad_join_server]
      ENV['NOMAD_CLIENT'] = host[:nomad_client]
      if host[:nomad_advertise_interface] then

        # Traivs specified.
        # IPAddress on Ruby: http://qiita.com/suu_g/items/a03af621f5d6985879e0
        require 'socket'
        private_ip = Socket.getifaddrs.select {|a|
          a.name == host[:nomad_advertise_interface] && a.addr.ipv4?
        }.first.addr.ip_address
        ENV['NOMAD_ADVERTISE_ADDR'] = private_ip
      end
      t.pattern = host[:pattern]
    end
  end
end
