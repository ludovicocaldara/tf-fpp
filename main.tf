# -----------------------------------------------
# main.tf
# 
# Here we declare a few basic variables and 
# instantiate the FPP Server and Client through the respective modules.
#
# The Networking is setup in network.tf as it is quite long.
# Tenancy and user-specific variables are in provider.tf
# -----------------------------------------------


# -----------------------------------------------------
# In theory it should be possible to use an existing VCN and subnet
# if they have already be defined in the compartment.
# In practice, I have not tested this yet =-)
# -----------------------------------------------------
variable "vcn_use_existing" {
  description = "Boolean: whether to use an existing subnet (true) or create a new one (false)"
  default = false
}

variable "subnet_public_existing" {
  description = "The ID of the existing subnet, same format as oci_core_subnet.<subnet>.id"
  default = ""
}

# -----------------------------------------------------
# I have written everything so that VCN and subnet CIDRs
# have to be modified just here.
# I have not tested with other addresses than 10.0.0.0/16 and 10.0.0.0/24
# but that should work
# -----------------------------------------------------
variable "vcn_cidr" {
  description = "CIDR block for the VCN. Security rules are created after this."
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet. Security rules and FPP IP addresses are created after this."
  default = "10.0.0.0/24"
}


locals {
  # get the subnet ID if it's a new subnet, or the variable otherwise
  public_subnet_id = var.vcn_use_existing ? var.subnet_public_existing : oci_core_subnet.public-subnet-fppll[0].id

  # timestamps, handy to have unique names for the resources
  timestamp_full = timestamp()
  timestamp = replace(local.timestamp_full, "/[- TZ:]/", "")
}


# -----------------------------------------------------
# Instantiate the FPP Client (OCI Compute) through the module.
# 
# There are many other variables that could be specified, just override them.
# (For the list, see modules/fppclient/variables.tf)
# -----------------------------------------------------
module "fppclient" {
  source                = "./modules/fppclient"
  availability_domain   = var.availability_domain_name
  compartment_id        = var.ociCompartmentOcid
  subnet_id             = local.public_subnet_id
  ssh_public_key        = var.ssh_public_key
  opc_private_key_path  = var.opc_private_key_path
  subnet_cidr           = var.subnet_cidr
  vcn_cidr              = var.vcn_cidr
  resId                 = var.resId
}

# -----------------------------------------------------
# Instantiate the FPP Server (OCI DBCS-VM 1-node) through the module.
# 
# There are many other variables that could be specified, just override them.
# (For the list, see modules/fppserver/variables.tf)
# -----------------------------------------------------
module "fppserver" {
  source                = "./modules/fppserver"
  nsg_ids               = [oci_core_network_security_group.fppll-network-security-group[0].id]
  availability_domain   = var.availability_domain_name
  compartment_id        = var.ociCompartmentOcid
  subnet_id             = local.public_subnet_id
  ssh_public_key        = var.ssh_public_key
  opc_private_key_path  = var.opc_private_key_path
  subnet_cidr           = var.subnet_cidr
  vcn_cidr              = var.vcn_cidr
  resId                 = var.resId
}
