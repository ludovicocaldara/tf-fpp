output "fppclient_name_and_ip" {
  value = [oci_core_instance.fppc_vm.hostname_label, oci_core_instance.fppc_vm.public_ip]
}

