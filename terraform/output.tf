output "fppserver" {
  value = format("FPP server %s has server name %s with IP address %s",
  module.fppserver.fppserver_db_system_name[0][0],
  module.fppserver.fppserver_name_and_ip[0],
  module.fppserver.fppserver_name_and_ip[1]
  )
}

output "fppclient" {
  value = format("FPP target has server name %s with IP address %s",
  module.fppclient.fppclient_name_and_ip[0],
  module.fppclient.fppclient_name_and_ip[1]
  )
}
