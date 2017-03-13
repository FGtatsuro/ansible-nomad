require "spec_helper_#{ENV['SPEC_TARGET_BACKEND']}"

describe command("nomad agent-info -address=http://#{ENV['NOMAD_SERVER_ADDR']}:4646") do
  its(:stdout) { should match /server = true/ }
  its(:stdout) { should match /leader_addr = #{ENV['NOMAD_SERVER_ADDR']}:4647/ }
  its(:stdout) { should match /raft_peers = #{ENV['NOMAD_SERVER_ADDR']}:4647/ }
end

describe command("nomad agent-info -address=http://#{ENV['NOMAD_CLIENT_ADDR']}:4646") do
  its(:stdout) { should match /client/ }
  its(:stdout) { should match /known_servers = 192.168.50.4:4647/ }
end

# After 'nomad init && nomad run -address=http://<serveraddr or clientaddr>:4646 example.nomad'
describe command("nomad status example") do
  its(:stdout) { should match /Status\s*= running/ }
end

if ENV['NOMAD_SERVER'] then
  describe command("docker ps") do
    its(:stdout) { should_not match /redis-/ }
  end
  describe command('nomad agent-info') do
    its(:stdout) { should match /server = true/ }
    its(:stdout) { should match /leader_addr = #{ENV['NOMAD_SERVER_ADDR']}:4647/ }
    its(:stdout) { should match /raft_peers = #{ENV['NOMAD_SERVER_ADDR']}:4647/ }
  end
else
  describe command("docker ps") do
    its(:stdout) { should match /redis-/ }
  end
  describe command('nomad agent-info') do
    its(:stdout) { should match /client/ }
    its(:stdout) { should match /known_servers = 192.168.50.4:4647/ }
  end
end

describe file('/var/log/nomad/stdout.log') do
  its(:content) { should match /Starting Nomad agent/ }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file('/var/log/nomad/stderr.log') do
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file('/var/run/nomad/nomad.pid') do
  it { should be_file }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end

describe file('/tmp/nomad') do
  it { should be_directory }
  it { should be_owned_by ENV['NOMAD_OWNER'] }
  it { should be_grouped_into ENV['NOMAD_GROUP'] }
end
