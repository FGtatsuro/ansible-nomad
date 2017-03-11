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
