require "spec_helper_#{ENV['SPEC_TARGET_BACKEND']}"

describe command('nomad version') do
  its(:exit_status) { should eq 0 }
end

describe command('nomad version'), :if => ['debian'].include?(os[:family]) do
  its(:stdout) { should contain("Nomad v0.4.1") }
end

describe file('/usr/local/bin/nomad') do
  it { should be_executable }
end

