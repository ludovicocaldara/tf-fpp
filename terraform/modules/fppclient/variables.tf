/*
********************
# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
********************
*/


variable "availability_domain" {}
variable "compartment_id" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "opc_private_key_path" {}


variable "vm_user" {
    default = "opc"
}
variable "vm_shape" {
    default = "VM.Standard.E3.Flex"
}

variable "instance_ocpus" {
  default = 2
}

variable "instance_memgb" {
  default = 32
}

variable "fppc_name" {
  default = "fppc"
}

variable "fppc_disk_size" {
  default = 100
}

variable "boot_volume_size_in_gbs" {
  default = 128
}

