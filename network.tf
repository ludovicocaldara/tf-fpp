# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------
# Setup the VCN.
# -----------------------------------------------
resource "oci_core_vcn" "fppll" {
  count          = var.vcn_use_existing ? 0 : 1
  cidr_block     = var.vcn_cidr
  dns_label      = "fppllvcn${var.resId}"
  compartment_id = var.compartment_ocid
  display_name   = "fppll-vcn-${var.resId}"
  lifecycle {
    ignore_changes = [
      display_name,
    ]
  }
}

# -----------------------------------------------
# Setup the Internet Gateway
# -----------------------------------------------
resource "oci_core_internet_gateway" "fppll-internet-gateway" {
  count          = var.vcn_use_existing ? 0 : 1
  compartment_id = var.compartment_ocid
  display_name   = "fppll-igw-${var.resId}"
  enabled        = "true"
  vcn_id         = oci_core_vcn.fppll[0].id
}

# -----------------------------------------------
# Setup the Route Table
# -----------------------------------------------
resource "oci_core_route_table" "fppll-public-rt" {
  count          = var.vcn_use_existing ? 0 : 1
  display_name   = "fppll-route-${var.resId}"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fppll[0].id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.fppll-internet-gateway[0].id
  }
}

# -----------------------------------------------
# Setup the Security List
# -----------------------------------------------
resource "oci_core_security_list" "fppll-security-list" {
  count          = var.vcn_use_existing ? 0 : 1
  display_name   = "fppll-seclist-${var.resId}"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fppll[0].id

  # -------------------------------------------
  # Egress: Allow everything
  # -------------------------------------------
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }


  # -------------------------------------------
  # Ingress protocol 6: TCP
  # -------------------------------------------

  # Allow SSH from everywhere
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow FFP ports range in the VCN
  # Ports 8894 and 8896 are for HTTPS and JMX
  # 8900 will be configured for the listener port 
  # 8901-8906 will be configured for the ractrans image transfer
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      min = 8894
      max = 8906
    }
  }

  # Allow SQL*Net communication within the VCN only
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      min = 1521
      max = 1531
    }
  }

  # ------------------------------------------
  # protocol 1: ICMP: allow explicitly from subnet and everywhere
  # ------------------------------------------
  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = 1
    source   = var.subnet_cidr
  }


  # ------------------------------------------
  # protocol 17: UCP
  # ------------------------------------------

  # Allow GNS port within the VCN
  ingress_security_rules {
    protocol = 17
    source   = var.vcn_cidr
    udp_options {
      min = 53
      max = 53
    }
  }

  # Allow NFS traffic within the VCN
  # (Note: NFS is not a requirement anymore for FPP
  #   unless you use remote image import from clients.
  #   This will be removed as well in the next RU.)
  ingress_security_rules {
    protocol = 17
    source   = var.vcn_cidr
    udp_options {
      min = 111
      max = 111
    }
  }
  ingress_security_rules {
    protocol = 17
    source   = var.vcn_cidr
    udp_options {
      min = 2049
      max = 2049
    }
  }
}


# ---------------------------------------------
# Setup the Security Group
# ---------------------------------------------
resource "oci_core_network_security_group" "fppll-network-security-group" {
  count          = var.vcn_use_existing ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fppll[0].id
  display_name   = "fppll-nsg-${var.resId}"
}

# ---------------------------------------------
# Setup the subnet
# ---------------------------------------------
resource "oci_core_subnet" "public-subnet-fppll" {
  count             = var.vcn_use_existing ? 0 : 1
  cidr_block        = var.subnet_cidr
  display_name      = "fppll-pubsubnet-${var.resId}"
  dns_label         = "pub${var.resId}"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.fppll[0].id
  route_table_id    = oci_core_route_table.fppll-public-rt[0].id
  security_list_ids = [oci_core_security_list.fppll-security-list[0].id]
}
