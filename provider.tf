# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
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
variable "ociCompartmentOcid" {
  description = "Your compartment OCID, eg: \"ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
}
variable "ociTenancyOcid" { 
  description = "Your tenancy OCID, eg: \"ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
}
variable "ociRegionIdentifier" { 
  description = "Your region, eg: \"uk-london-1\""
}
variable "availability_domain_name" { 
  description = "Your availability domain, eg: \"OUGC:UK-LONDON-1-AD-1\""
}

# ----------------------------------
# OCI User information for API access
# ----------------------------------
variable "ociUserOcid" { 
  description = "Your compartment OCID, eg: \"ocid1.user.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
}
variable "fingerprint" { 
  description = "Your user fingerprint, eg: \"de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef\""
}
variable "private_key_path" { 
  description = "Path to your PEM key for OCI APIs, eg: \"~/.ssh/oci.pem\""
}


# ----------------------------------
# SSH keys for opc remote access
#
# Because the terraform code requires to connect via ssh to perform some setups,
# both private and public keys are required.
# People cloning from git for their paid tenancy can provide these two variables
# in override.tf.

# ----------------------------------
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
  default = "1234"
}

variable "resUserPublicKey" {
  description = "LiveLab users will upload their public SSH key, this is what will be used to give them access as opc. For github users, this might be an additional public key for access as opc"
  default = ""
}


# -------------------------
# Setup the OCI provider...
# -------------------------
provider "oci" {
  tenancy_ocid = var.ociTenancyOcid
  user_ocid = var.ociUserOcid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  region = var.ociRegionIdentifier
}
