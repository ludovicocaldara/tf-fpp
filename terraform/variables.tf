variable "vcn_use_existing" {
  default = false
}

variable "subnet_public_existing" {
  default = ""
}

locals {
  public_subnet_id = var.vcn_use_existing ? var.subnet_public_existing : oci_core_subnet.public-subnet-fppll[0].id
  timestamp_full = timestamp()
  timestamp = replace(local.timestamp_full, "/[- TZ:]/", "")
}

