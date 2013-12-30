#default['zabbix-server']['version'] = "2.0.6-1"
default['zabbix']['version']['major'] = "2.2"
default['zabbix-server']['packages']['zabbix'] = %w{
  zabbix
  zabbix-agent
  zabbix-get
  zabbix-java-gateway
  zabbix-sender
  zabbix-server-pgsql
  zabbix-web
  zabbix-web-japanese
  zabbix-web-pgsql
}
default['zabbix-server']['packages']['other'] = %w{
  snmptt
  postgresql-server
  crontabs
  net-snmp-utils
  net-snmp-perl
  ntp
  tcpdump
  telnet
  vim-enhanced
  bind-utils
  man
}
default['zabbix-proxy']['packages']['zabbix'] = %w{
  zabbix
  zabbix-get
  zabbix-java-gateway
  zabbix-sender
  zabbix-proxy-pgsql
}
default['zabbix-proxy']['packages']['other'] = %w{
  snmptt
  postgresql-server
  crontabs
  net-snmp-utils
  net-snmp-perl
  ntp
  tcpdump
  telnet
  vim-enhanced
  bind-utils
  man
}
default['zabbix-proxy']['server'] = ""

