#
# Cookbook Name:: zabbix-server
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "disable selinux enforcement" do
  only_if "which selinuxenabled && selinuxenabled"
  command "setenforce 0"
  action :run
  notifies :create, "template[/etc/selinux/config]"
end

template "/etc/selinux/config" do
  source "config.erb"
  owner "root"
  mode 0644
end

remote_file "/tmp/zabbix-release-2.0-1.el6.noarch.rpm" do
  source "http://repo.zabbix.com/zabbix/2.0/rhel/6/x86_64/zabbix-release-2.0-1.el6.noarch.rpm"
  mode "0644"
end

package "zabbix-release" do
  action :install
  source "/tmp/zabbix-release-2.0-1.el6.noarch.rpm"
  provider Chef::Provider::Package::Rpm
end

remote_file "/tmp/epel-release-6-8.noarch.rpm" do
  source "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
  mode "0644"
end

package "epel-release" do
  action :install
  source "/tmp/epel-release-6-8.noarch.rpm"
  provider Chef::Provider::Package::Rpm
end

package "zabbix" do
  action :install
end

package "zabbix-agent" do
  action :install
end

package "zabbix-get" do
  action :install
end

package "zabbix-java-gateway" do
  action :install
end

package "zabbix-sender" do
  action :install
end

package "zabbix-server-pgsql" do
  action :install
end

package "zabbix-web" do
  action :install
end

package "zabbix-web-japanese" do
  action :install
end

package "zabbix-web-pgsql" do
  action :install
end

package "snmptt" do
  action :install
end

package "postgresql-server" do
  action :install
end

package "crontabs" do
  action :install
end

package "net-snmp-utils" do
  action :install
end

package "ntp" do
  action :install
end

package "tcpdump" do
  action :install
end

package "telnet" do
  action :install
end

package "telnet" do
  action :install
end

package "vim" do
  action :install
end

package "bind-utils" do
  action :install
end

package "man" do
  action :install
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
   command "createuser -U postgres -S -d -R zabbix"
   not_if code 
end

execute "create-database-user" do
	 exists = <<-EOH
	 psql -U postgres -c "select * from pg_database WHERE datname='zabbix'" | grep -c zabbix
	 EOH
   command "createdb -U zabbix zabbix"
    not_if exists
end


execute "create-schema" do
   command "psql -f /usr/share/doc/zabbix-server-pgsql-2.0.5/create/schema.sql -U zabbix zabbix"
end

execute "create-schema-images" do
   command "psql -f /usr/share/doc/zabbix-server-pgsql-2.0.5/create/images.sql -U zabbix zabbix"
end


# execute "selinux" do
#    command "/usr/sbin/setenforce 0"
# end

template "/var/lib/pgsql/data/reindex" do
  source "reindex.erb"
  owner "root"
  mode 0644
end

template "/etc/cron.d/postgresql_maintenance" do
  source "postgresql_maintenance.erb"
  owner "root"
  mode 0644
end

template "/etc/zabbix/zabbix_server.conf" do
  source "zabbix_server.conf.erb"
  owner "root"
  notifies :restart, "service[zabbix-server]"
  mode 0640
end

template "/etc/zabbix/web/zabbix.conf.php" do
  source "zabbix.conf.php.erb"
  owner "root"
  notifies :restart, "service[zabbix-server]"
  mode 0644
end

template "/etc/php.ini" do
  source "php.ini.erb"
  owner "root"
  notifies :restart, "service[httpd]"
  mode 0644
end

template "/etc/httpd/conf/httpd.conf" do
  source "httpd.conf.erb"
  owner "root"
  notifies :restart, "service[httpd]"
  mode 0644
end

service "zabbix-server" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "zabbix-agent" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "httpd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
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

service "snmptrapd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "snmptt" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

execute "create-schema-data" do
   command "psql -f /usr/share/doc/zabbix-server-pgsql-2.0.5/create/data.sql -U zabbix zabbix"
end

