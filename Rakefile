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
      :pattern  =>  'spec/nomad_spec.rb,spec/nomad_daemon_dev_spec.rb'
    },
    {
      :name     =>  'container',
      :backend  =>  'docker',
      :nomad_config_remote_dir =>  '/etc/nomad.d',
      :nomad_owner  =>  'nomad',
      :nomad_group  =>  'nomad',
      :pattern  =>  'spec/nomad_spec.rb'
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
      ENV['NOMAD_ADVERTISE_ADDR'] = nil
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
