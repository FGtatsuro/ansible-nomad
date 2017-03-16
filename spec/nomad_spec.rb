require "spec_helper_#{ENV['SPEC_TARGET_BACKEND']}"

describe command('nomad version') do
  its(:exit_status) { should eq 0 }
end

describe command('nomad version'), :if => ['debian'].include?(os[:family]) do
  its(:stdout) { should contain("Nomad v0.5.4") }
end

describe file('/usr/local/bin/nomad') do
  it { should be_executable }
end

describe file('/opt/nomad/daemons.py') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
  its(:content) { should match /#{Regexp.escape('/var/log/nomad/stdout.log')}/ }
  its(:content) { should match /#{Regexp.escape('/var/log/nomad/stderr.log')}/ }
  its(:content) { should match /#{Regexp.escape('/var/run/nomad/nomad.pid')}/ }
  its(:content) { should match /#{Regexp.escape("-config=#{ENV['NOMAD_CONFIG_REMOTE_DIR']}")}/ }
end

[
  'python-daemon',
  'click'
].each  do |p|
  describe package(p) do
    it { should be_installed.by(:pip) }
  end
end

describe file('/var/log/nomad') do
  it { should be_directory }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file('/var/run/nomad/') do
  it { should exist }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file(ENV['NOMAD_CONFIG_REMOTE_DIR']) do
  it { should be_directory }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

# Common settings
describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
  it { should be_file }
  it { should be_readable }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
  its(:content) { should match /#{Regexp.escape('data_dir = "/tmp/nomad"')}/ }
  its(:content) { should match /#{Regexp.escape('bind_addr = "0.0.0.0"')}/ }
  its(:content) { should match /#{Regexp.escape('datacenter = "dc1"')}/ }
end

if ENV['NOMAD_ADVERTISE_CONFIG_ADDR'] then
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should match /advertise/ }
    its(:content) { should match /#{Regexp.escape("http = \"#{ENV['NOMAD_ADVERTISE_CONFIG_ADDR']}\"")}/ }
    its(:content) { should match /#{Regexp.escape("rpc = \"#{ENV['NOMAD_ADVERTISE_CONFIG_ADDR']}\"")}/ }
    its(:content) { should match /#{Regexp.escape("serf = \"#{ENV['NOMAD_ADVERTISE_CONFIG_ADDR']}\"")}/ }
  end
else
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should_not match /advertise {/ }
    its(:content) { should_not match /http =/ }
    its(:content) { should_not match /rpc =/ }
    its(:content) { should_not match /serf =/ }
  end
end

if ENV['NOMAD_CONSUL_ADDRESS'] then
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should match /consul {/ }
    its(:content) { should match /#{Regexp.escape("address = \"#{ENV['NOMAD_CONSUL_ADDRESS']}\"")}/ }
  end
else
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should_not match /consul {/ }
    its(:content) { should_not match /address = / }
  end
end

if ENV['NOMAD_JOIN_SERVER'] then
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should match /client {\n(.*\n){0,2}  #{Regexp.escape("servers = [\"#{ENV['NOMAD_JOIN_SERVER']}\"]")}/ }
  end
else
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should_not match /client {\n(.*\n){0,2}  #{Regexp.escape('servers = [')}/ }
  end
end

if ENV['NOMAD_CLIENT'] then
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should match /client {\n(.*\n){0,2}  enabled = #{ENV['NOMAD_CLIENT']}/ }
  end
else
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should_not match /client {\n(.*\n){0,2}  enabled =/ }
  end
end

if ENV['NOMAD_BOOTSTRAP_EXPECT'] then
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should match /server {\n(.*\n){0,2}  bootstrap_expect = #{ENV['NOMAD_BOOTSTRAP_EXPECT']}/ }
  end
else
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should_not match /server {\n(.*\n){0,2}  bootstrap_expect =/ }
  end
end

if ENV['NOMAD_SERVER'] then
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should match /server {\n(.*\n){0,2}  enabled = #{ENV['NOMAD_SERVER']}/ }
  end
else
  describe file("#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/nomad_common.hcl") do
    its(:content) { should_not match /server {\n(.*\n){0,2}  enabled =/ }
  end
end

# Custom settings
[
  "#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/server.hcl",
  "#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/client.hcl"
].each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by ENV['NOMAD_OWNER'] }
    it { should be_grouped_into ENV['NOMAD_GROUP'] }
  end
end
