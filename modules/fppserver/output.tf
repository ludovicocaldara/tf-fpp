# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# -------------------------------------------------------------------------------------
# Outputs the dbsystem name, hostname label and public IP that will be printed by the terraform root
# -------------------------------------------------------------------------------------
output "fppserver_db_system_name" {
  value = [oci_database_db_system.fppll_db_system.*.display_name]
}

output "fppserver_name_and_ip" {
  value = [data.oci_core_vnic.fppll_vnic.hostname_label, data.oci_core_vnic.fppll_vnic.public_ip_address]
}
