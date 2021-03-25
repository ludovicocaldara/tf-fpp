
variable "compartment_ocid" { }
variable "tenancy_ocid" { }
variable "region" { }
variable "availability_domain_name" { }
variable "user_ocid" { }
variable "fingerprint" { }
variable "private_key_path" { }
variable "opc_private_key_path" { }
variable "ssh_public_key" { }


provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  region = var.region
}
