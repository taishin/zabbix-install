#
# Cookbook Name:: zabbix-proxy
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file "#{Chef::Config[:file_cache_path]}/zabbix-release-2.0-1.noarch.rpm" do
  source "http://repo.zabbix.com/zabbix/2.0/rhel/#{node[:platform_version].to_i}/#{node[:kernel][:machine]}/zabbix-release-2.0-1.el#{node[:platform_version].to_i}.noarch.rpm"
end


package "zabbix-release" do
  action :install
  source "#{Chef::Config[:file_cache_path]}/zabbix-release-2.0-1.noarch.rpm"
  provider Chef::Provider::Package::Rpm
end

remote_file "#{Chef::Config[:file_cache_path]}/epel-release.noarch.rpm" do
  source "http://dl.fedoraproject.org/pub/epel/#{node[:platform_version].to_i}/#{node[:kernel][:machine]}/epel-release-#{node[:platform_version].to_i}-8.noarch.rpm"
end

package "epel-release" do
  action :install
  source "#{Chef::Config[:file_cache_path]}/epel-release.noarch.rpm"
  provider Chef::Provider::Package::Rpm
end

node['zabbix-proxy']['packages']['zabbix'].each do |pkg|
  package pkg do
    version "#{node['zabbix-server']['version']}.el#{node[:platform_version].to_i}"
    action :install
  end
end

node['zabbix-proxy']['packages']['other'].each do |pkg|
  package pkg do
    action :install
  end
end

execute "selinux" do
  command "/usr/sbin/setenforce 0"
  only_if { `/usr/sbin/getenforce` =~ /Enforcing/ }
end

template "/etc/selinux/config" do
  source "config.erb"
  owner "root"
  mode 0644
end


execute "/sbin/service postgresql initdb" do
  not_if { ::FileTest.exist?("/var/lib/pgsql/data/postgresql.conf") }
end

template "/var/lib/pgsql/data/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  mode 0600
end

template "/var/lib/pgsql/data/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  mode 0600
end

service "postgresql" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

execute "create-database-user" do
  code = <<-EOH
  psql -U postgres -c "select * from pg_user where usename='zabbix'" | grep -c zabbix
  EOH
  command "createuser -U postgres zabbix -S -d -R"
  not_if code 
end

execute "create-database" do
  exists = <<-EOH
  psql -U postgres -c "select * from pg_database WHERE datname='zabbix_proxy'" | grep -c zabbix
  EOH
  command "createdb -U zabbix zabbix_proxy"
  not_if exists
end

#script "create_zabbix_table" do
#  interpreter "bash"
#  user "root"
#  code <<-EOH
#  psql -f /usr/share/doc/`rpm -q zabbix-proxy-pgsql | sed -e s/-.\.el.\.x86_64//`/create/schema.sql -U zabbix zabbix_proxy
#  EOH
#end
#  psql -f /usr/share/doc/`rpm -q zabbix-proxy-pgsql | sed -e s/-.\.el.\.x86_64//`/create/images.sql -U zabbix zabbix_proxy
#  psql -f /usr/share/doc/`rpm -q zabbix-proxy-pgsql | sed -e s/-.\.el.\.x86_64//`/create/data.sql -U zabbix zabbix_proxy

template "/etc/cron.d/postgresql_maintenance" do
  source "postgresql_maintenance.erb"
  owner "root"
  mode 0644
end

template "/etc/zabbix/zabbix_proxy.conf" do
  source "zabbix_proxy.conf.erb"
  owner "root"
  notifies :restart, 'service[zabbix-proxy]'
  mode 0640
end

service "zabbix-proxy" do
  supports :status => true, :restart => true
  action [ :enable, :start]
end

service "zabbix-java-gateway" do
  supports :status => true, :restart => true
  action [ :enable, :start]
end

service "iptables" do
  supports :status => true, :restart => true, :reload => true
  action [ :disable, :stop ]
end

service "ip6tables" do
  supports :status => true, :restart => true, :reload => true
  action [ :disable, :stop ]
end

template "/etc/snmp/snmptrapd.conf" do
  source "snmptrapd.conf.erb"
  owner "root"
  notifies :restart, "service[snmptrapd]"
  mode 0644
end

template "/etc/sysconfig/snmptrapd" do
  source "snmptrapd.erb"
  owner "root"
  notifies :restart, "service[snmptrapd]"
  mode 0644
end

template "/etc/snmp/snmptt.conf" do
  source "snmptt.conf.erb"
  owner "root"
  notifies :restart, "service[snmptt]"
  mode 0644
end

template "/etc/snmp/snmptt.ini" do
  source "snmptt.ini.erb"
  owner "root"
  notifies :restart, "service[snmptt]"
  mode 0644
end

cookbook_file "#{Chef::Config[:file_cache_path]}/vendor-mib.tar.gz" do
  source "vendor-mib.tar.gz"
end

cookbook_file "#{Chef::Config[:file_cache_path]}/snmpttconf.tar.gz" do
  source "snmpttconf.tar.gz"
end

script "install_mib" do
  interpreter "bash"
  user "root"
  code <<-EOL
    tar xzvf #{Chef::Config[:file_cache_path]}/vendor-mib.tar.gz -C /usr/share/snmp/mibs
  EOL
  not_if {::File.exists?("/usr/share/snmp/mibs/cisco")}
end

script "install_snmpttconf" do
  interpreter "bash"
  user "root"
  code <<-EOL
    tar xzvf #{Chef::Config[:file_cache_path]}/snmpttconf.tar.gz -C /etc/snmp
  EOL
  not_if {::File.exists?("/etc/snmp/snmpttconf")}
  notifies :restart, "service[snmptt]" 
end


template "/etc/snmp/snmp.conf" do
  source "snmp.conf.erb"
  owner "root"
  mode 0644
end

service "snmptrapd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "snmptt" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

