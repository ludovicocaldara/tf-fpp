# ----------------------------------------------------
# These variables are passed by the terraform root
# ----------------------------------------------------
variable "nsg_ids" {}
variable "availability_domain" {}
variable "compartment_id" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "opc_private_key_path" {}
variable "subnet_cidr" {}
variable "vcn_cidr" {}

# ----------------------------------------------------
# decent defaults:
# ----------------------------------------------------
variable "db_system_shape" {
  description = "DB system shape to use for the FPP server."
  default = "VM.Standard2.2"
}

variable "system_count" {
  description = "How many fppserver DB systems. Don't put more than 1 unless you know what you are doing."
  default = 1
}

variable "vm_user" {
  description = "SSH user to connect to the fpp server for the setup. Must have sudo privilege."
  default = "opc"
}

variable "node_count" {
  description = "Number of nodes in the fppserver Grid Infrastructure cluster. Use 1 for test and dev."
  default = "1"
}

variable "db_edition" {
  description = "Database edition. Must be EE-EP to use RAC, not mandatory for the FPP server if 1 node setup."
  default = "ENTERPRISE_EDITION_EXTREME_PERFORMANCE"
}

# ----------------------------------------------------------
# we don't really care about the database being created,
# because we will use the system as FPP server, not as DB server.
# But there are no ways to skip the database creation, so we'll just keep it.
#
# Note:
# there is no full layer 2 support in the OCI network.
# A full GI setup requires it (GI needs multicast), that's why we use DBCS and not a compute instance.
# ----------------------------------------------------------

variable "db_admin_password" {
  description = "Default sys/system password for the DB System database."
  default = "Welcome#Welcome#123"
}

variable "n_character_set" {
  default = "AL16UTF16"
}

variable "character_set" {
  default = "AL32UTF8"
}

variable "db_workload" {
  default = "OLTP"
}

variable "cdb_name" {
  default = "cdbtst01"
}

variable "pdb_name" {
  default = "pdbtst01"
}

variable "db_disk_redundancy" {
  description = "ASM disk redundancy. Use HIGH for production, NORMAL otherwise."
  default = "NORMAL"
}

variable "db_version" {
  description = "Version for the DB system. This lab supports 19c, don't use 21c yet."
  default = "19.9.0.0"
}

variable "data_storage_size_in_gb" {
  description = "ASM space in GB. 256 is a good default to host also the FPP Server storage."
  default = "256"
}

variable "license_model" {
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "gns_ip_offset" {
  description = "The IP offset to assign to GNS in the subnet CIDR block."
  default = 100
}

variable "ha_vip_offset" {
  description = "The IP offset to assign to HAVIP in the subnet CIDR block."
  default = 101
}

variable "fppserver_display_name" {
  description = "name for the dbsystem"
  default = "fpps-cluster"
}

variable "fppserver_prefix" {
  description = "The prefix to use for the FPP server host name."
  default = "fpps"
}


locals {
  timestamp_full = timestamp()
  timestamp = replace(local.timestamp_full, "/[- TZ:]/", "")
}

