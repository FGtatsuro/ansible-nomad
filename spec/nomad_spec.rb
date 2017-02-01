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

[
  "#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/server.hcl",
  "#{ENV['NOMAD_CONFIG_REMOTE_DIR']}/client.hcl"
].each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by ENV['NOMAD_CONFIG_OWNER'] }
    it { should be_grouped_into ENV['NOMAD_CONFIG_GROUP'] }
  end
end
