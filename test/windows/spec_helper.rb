#require 'serverspec'
#require 'pathname'
#require 'winrm'
#set :backend, :winrm
#set :os, :family => 'windows'

#user = 'vagrant'
#pass = 'vagrant'
##endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"
#endpoint = "http://10.128.139.116:5985/wsman"
#winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
#winrm.set_timeout 300 # 5 minutes max timeout for any operation
#Specinfra.configuration.winrm = winrm
