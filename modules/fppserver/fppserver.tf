###################################################
# declaration of the templates scripts for FPP setup
data "template_file" "repo_setup" {
  template = file("${path.module}/scripts/01_repo_setup.sh")
}

data "template_file" "mgmtdb_setup" {
  template = file("${path.module}/scripts/02_mgmtdb_setup.sh")
}

data "template_file" "fpp_setup" {
  template = file("${path.module}/scripts/03_fpp_setup.sh")

  vars = {
    gns_ip         = cidrhost(var.subnet_cidr, var.gns_ip_offset)
    ha_vip         = cidrhost(var.subnet_cidr, var.ha_vip_offset)
  }

}

locals {
  repo_script      = "/tmp/01_repo_setup.sh"
  mgmtdb_script    = "/tmp/02_mgmtdb_setup.sh"
  fpp_script       = "/tmp/03_fpp_setup.sh"
  dhclient_script  = "/tmp/dhclient.sh"
  dhclient_setup   = file("${path.module}/scripts/set-domain.sh")
}


###################################################
# data sources db_nodes and vnic to output the public_ip_address and hostname at the end of the deployment
data "oci_database_db_nodes" "fppll_db_nodes" {
    compartment_id = var.compartment_id
    db_system_id = oci_database_db_system.fppll_db_system[0].id
}

data "oci_core_vnic" "fppll_vnic" {
    vnic_id = data.oci_database_db_nodes.fppll_db_nodes.db_nodes[0].vnic_id
}

###################################################
# creation of the db_system. It is necessary to create a full db_system to bypass compute instance multicast limitation without strange hacks.
# the database itself is useless on the FPP server but might be interesting for testing purposes, therefore we give it a test name
resource "oci_database_db_system" "fppll_db_system" {
  count               = var.system_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  database_edition    = var.db_edition

  db_home {
    database {
      admin_password = var.db_admin_password
      db_name        = var.cdb_name
      character_set  = var.character_set
      ncharacter_set = var.n_character_set
      db_workload    = var.db_workload
      pdb_name       = var.pdb_name

      db_backup_config {
        auto_backup_enabled = false
      }
    }

    db_version   = var.db_version
    display_name = "fppll-fppsdbsys-${var.resId}"
  }

  db_system_options {
    storage_management = "ASM"
  }

  disk_redundancy         = var.db_disk_redundancy
  shape                   = var.db_system_shape
  subnet_id               = var.subnet_id
  ssh_public_keys         = [var.ssh_public_key]
  display_name            = "${var.fppserver_display_name}-${var.resId}"
  hostname                = "${var.fppserver_prefix}${format("%02d", count.index + 1)}"
  data_storage_size_in_gb = var.data_storage_size_in_gb
  license_model           = var.license_model
  node_count              = var.node_count
  nsg_ids                 = var.nsg_ids
  lifecycle {
    ignore_changes = [
      display_name, hostname,
    ]
  }
}


resource "null_resource" "fpp_provisioner" {
  depends_on = [oci_database_db_system.fppll_db_system]

  provisioner "file" {
    content     = data.template_file.repo_setup.rendered
    destination = local.repo_script
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }
  provisioner "file" {
    content     = data.template_file.mgmtdb_setup.rendered
    destination = local.mgmtdb_script
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }
  provisioner "file" {
    content     = data.template_file.fpp_setup.rendered
    destination = local.fpp_script
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "30m"
      user        = var.vm_user
      private_key = var.ssh_private_key
    }
   
    inline = [
       "chmod +x ${local.repo_script}",
       "sudo ${local.repo_script}",
       "chmod +x ${local.mgmtdb_script}",
       "sudo -u grid ${local.mgmtdb_script}",
       "chmod +x ${local.fpp_script}",
       "sudo ${local.fpp_script}"
    ]

   }
}

resource "null_resource" "dhclient_resolv_setup" {
  depends_on = [oci_database_db_system.fppll_db_system, null_resource.fpp_provisioner]

  provisioner "file" {
    content     = "export PRESERVE_HOSTINFO=3"
    destination = "/tmp/oci-hostname.conf"
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }
  provisioner "file" {
    content     = local.dhclient_setup
    destination = local.dhclient_script
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }
  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.fppll_vnic.public_ip_address
      agent       = false
      timeout     = "1m"
      user        = var.vm_user
      private_key = var.ssh_private_key
    }
   
    inline = [
       "sudo mv ${local.dhclient_script} /etc/dhcp/dhclient-exit-hooks.d/set-domain.sh",
       "sudo mv /tmp/oci-hostname.conf /etc/oci-hostname.conf",
       "sudo chmod 644 /etc/oci-hostname.conf",
       "sudo chown root:root /etc/oci-hostname.conf",
       "sudo chmod 755 /etc/dhcp/dhclient-exit-hooks.d/set-domain.sh",
       "sudo new_ip_address=${data.oci_core_vnic.fppll_vnic.private_ip_address} reason=RENEW  /etc/dhcp/dhclient-exit-hooks.d/set-domain.sh"
    ]

   }

}
