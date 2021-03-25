# ------------------------------------------------------------------------
# All the variables that are unique to your user / tenancy
# 
# If you fork from github, copy this file to "override.tf"
# so that your variables are not versioned publicly :-)
# ------------------------------------------------------------------------
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
variable "user_ocid" { 
  description = "Your compartment OCID, eg: \"ocid1.user.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
}
variable "fingerprint" { 
  description = "Your user fingerprint, eg: \"de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef\""
}
variable "private_key_path" { 
  description = "Path to your PEM key for OCI APIs, eg: \"~/.ssh/oci.pem\""
}
variable "opc_private_key_path" { 
  description = "Path to your private SSH key for the SSH connections as opc, eg: \"~/.ssh/id_rsa\""
}
variable "ssh_public_key" { 
  description = "Public SSH key string corresponding to the private \"opc_private_key_path\" private key. e.g. \"ssh-rsa AAAAAAAAAA...longlongstring..AAAAAAAAAA\""
}


# -------------------------
# Setup the OCI provider...
# -------------------------
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  region = var.region
}
