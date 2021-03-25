/*
********************
# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
********************
*/

resource "oci_core_vcn" "fppll" {
  count          = var.vcn_use_existing ? 0 : 1
  cidr_block     = "10.0.0.0/16"
  dns_label      = "fpplivelab"
  compartment_id = var.compartment_ocid
  display_name   = "fppll-net-${local.timestamp}"
  lifecycle {
    ignore_changes = [
      display_name,
    ]
  }
}

resource "oci_core_internet_gateway" "fppll-internet-gateway" {
  count          = var.vcn_use_existing ? 0 : 1
  compartment_id = var.compartment_ocid
  display_name   = "fppll Internet Gateway"
  enabled        = "true"
  vcn_id         = oci_core_vcn.fppll[0].id
}

resource "oci_core_route_table" "fppll-public-rt" {
  count          = var.vcn_use_existing ? 0 : 1
  display_name   = "fppll Route Table"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fppll[0].id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.fppll-internet-gateway[0].id
  }
}

resource "oci_core_security_list" "fppll-security-list" {
  count          = var.vcn_use_existing ? 0 : 1
  display_name   = "fppll Security List"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fppll[0].id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // protocol 6: TCP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8894
      max = 8906
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 1521
      max = 1531
    }
  }

  // protocol 1: ICMP
  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = 1
    source   = "10.0.0.0/16"
  }
  ingress_security_rules {
    protocol = 17
    source   = "10.0.0.0/16"
    udp_options {
      min = 53
      max = 53
    }
  }
  ingress_security_rules {
    protocol = 17
    source   = "10.0.0.0/16"
    udp_options {
      min = 111
      max = 111
    }
  }
  ingress_security_rules {
    protocol = 17
    source   = "10.0.0.0/16"
    udp_options {
      min = 2049
      max = 2049
    }
  }
}


resource "oci_core_network_security_group" "fppll-network-security-group" {
  count          = var.vcn_use_existing ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fppll[0].id
  display_name   = "fppll network security group"
}

resource "oci_core_subnet" "public-subnet-fppll" {
  count             = var.vcn_use_existing ? 0 : 1
  cidr_block        = "10.0.0.0/24"
  display_name      = "fppll Public Subnet"
  dns_label         = "pub"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.fppll[0].id
  route_table_id    = oci_core_route_table.fppll-public-rt[0].id
  security_list_ids = [oci_core_security_list.fppll-security-list[0].id]
}
