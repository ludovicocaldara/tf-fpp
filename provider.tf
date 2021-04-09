# ------------------------------------------------------------------------
# All the variables that are unique to your user / tenancy
# 
# If you fork from github, copy this file to "override.tf"
# so that your variables are not versioned publicly :-)
# override.tf is skipped by the .gitignore file
# ------------------------------------------------------------------------


# ----------------------------------
# Tenancy information
# ----------------------------------
variable "compartment_ocid" {
  description = "Your compartment OCID, eg: \"ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
}
variable "tenancy_ocid" { 
  description = "Your tenancy OCID, eg: \"ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
}
variable "region" { 
  description = "Your region, eg: \"uk-london-1\""
}
variable "availability_domain_name" { 
  description = "Your availability domain, eg: \"OUGC:UK-LONDON-1-AD-1\""
}

variable "ssh_private_key" { 
  description = "Private SSH key string corresponding to the ssh_public_key. e.g. \"-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAu5x2wLr2oH06VQqpkCih8a+g3njxoXu/GZ0pIWWPh2tmbK8B\nIQI0uG3NXt7l46JZEku0UoF1q+N4xMuRL1iSMFPpZhXiuP2igiu9Kh+RGPYXkhJl[...]-----END RSA PRIVATE KEY-----\n\""

}
variable "ssh_public_key" { 
  description = "Public SSH key string corresponding to the private \"opc_private_key_path\" private key. e.g. \"ssh-rsa AAAAAAAAAA...longlongstring..AAAAAAAAAA\""
}


# ---------------------------------
# LiveLab specific:
# ---------------------------------

variable "resId" {
  description = "Reservations in livelab have a specific identifier. The green button will override this variable with that identifier."
  default = "LL000"
}

variable "resUserPublicKey" {
  description = "LiveLab users will upload their public SSH key, this is what will be used to give them access as opc."
}


# -------------------------
# Setup the OCI provider...
# -------------------------
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region = var.region
}
