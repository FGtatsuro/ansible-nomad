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
      :nomad_group  =>  'staff'
    },
    {
      :name     =>  'container',
      :backend  =>  'docker',
      :nomad_config_remote_dir =>  '/etc/nomad.d',
      :nomad_owner  =>  'root',
      :nomad_group  =>  'root'
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
      t.pattern = "spec/nomad_spec.rb"
    end
  end
end
