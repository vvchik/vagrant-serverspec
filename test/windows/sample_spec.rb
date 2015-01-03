require_relative 'spec_helper'

#describe file('C:\\programdata\\chocolatey\\bin\\console.exe') do
#  it { should be_file }
#end

describe windows_feature('Web-Server') do
  it{ should be_installed.by("powershell") }
end

#describe windows_registry_key(
#  'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\advanced') do
#  it { should have_property_value('Hidden', :type_dword,'1') }
#end

describe command('Get-ExecutionPolicy') do
  its(:stdout) { should match /RemoteSigned/ }
  #its(:stderr) { should match /stderr/ }
  its(:exit_status) { should eq 0 }
end

#describe iis_website('Default Website') do
#  it{ should have_site_bindings(80) }
#end

describe port(80) do
  it { should be_listening }
end

describe file('C:\Windows\system32\telnet.exe') do
  it { should be_file }
end

describe windows_feature('TelnetClient') do
  it{ should be_installed.by("powershell") }
end
