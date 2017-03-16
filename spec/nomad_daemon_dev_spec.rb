require "spec_helper_#{ENV['SPEC_TARGET_BACKEND']}"

[
  # 'nomad agent-info',
  "nomad agent-info -address=http://#{ENV['NOMAD_ADVERTISE_ADDR']}:4646"
].each do |c|
  describe command(c) do
    its(:stdout) { should match /known_servers = #{ENV['NOMAD_ADVERTISE_ADDR']}:4647/ }
    its(:stdout) { should match /leader_addr = #{ENV['NOMAD_ADVERTISE_ADDR']}:4647/ }
  end
end

describe file('/var/log/nomad/stdout.log') do
  its(:content) { should match /Starting Nomad agent/ }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file('/var/log/nomad/stderr.log') do
  its(:size) { should eq 0 }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file('/var/run/nomad/nomad.pid') do
  it { should be_file }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end
