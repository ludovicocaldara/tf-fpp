
variable "compartment_ocid" {
}
variable "tenancy_ocid" {
}
variable "region" {
}
variable "availability_domain_name" {
}
variable "user_ocid" {
}
variable "fingerprint" {
}
variable "private_key_path" {
}


provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  region = var.region
}
