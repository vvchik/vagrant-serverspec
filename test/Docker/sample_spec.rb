require_relative 'spec_helper'

describe package('vim') do
  it { should be_installed }
end

describe file('/tmp/testfile') do
  it { should be_file }
end
