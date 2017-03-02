require "spec_helper_#{ENV['SPEC_TARGET_BACKEND']}"

[
  # 'nomad agent-info',
  "nomad agent-info -address=http://#{ENV['NOMAD_ADVERTISE_ADDR']}:4646"
].each do |c|
  describe command(c) do
    its(:stdout) { should match /known_servers = #{ENV['NOMAD_ADVERTISE_ADDR']}:4647/ }
    its(:stdout) { should match /leader_addr = #{ENV['NOMAD_ADVERTISE_ADDR']}:4647/ }
    its(:stdout) { should match /raft_peers = #{ENV['NOMAD_ADVERTISE_ADDR']}:4647/ }
  end
end
