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
