module "fppclient" {
  source                = "./modules/fppclient"
  availability_domain   = var.availability_domain_name
  compartment_id        = var.compartment_ocid
  subnet_id             = local.public_subnet_id
  ssh_public_key        = var.ssh_public_key
  opc_private_key_path  = var.opc_private_key_path
}

