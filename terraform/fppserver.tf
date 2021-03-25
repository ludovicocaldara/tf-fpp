module "fppserver" {
  source                = "./modules/fppserver"
  nsg_ids               = [oci_core_network_security_group.fppll-network-security-group[0].id]
  availability_domain   = var.availability_domain_name
  compartment_id        = var.compartment_ocid
  subnet_id             = local.public_subnet_id
  ssh_public_key       = var.ssh_public_key
  opc_private_key_path  = var.opc_private_key_path
}
