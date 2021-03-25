# ---------------------------------------------------------
# declaration of the templates scripts for FPP setup
# ---------------------------------------------------------
data "template_file" "repo_setup" {
  template = file("${path.module}/scripts/01_repo_setup.sh")
}

data "template_file" "u01_setup" {
  template = file("${path.module}/scripts/02_u01_setup.sh")

  vars = {
	attachment_type = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[0].attachment_type
	ipv4            = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[0].ipv4
	iqn             = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[0].iqn
	port            = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[0].port
	vcn_cidr        = var.vcn_cidr
  }
}

data "template_file" "asmdisk_setup" {
  template = file("${path.module}/scripts/03_asmdisk_setup.sh")

  vars = {
	attachment_type = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[1].attachment_type
	ipv4            = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[1].ipv4
	iqn             = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[1].iqn
	port            = data.oci_core_volume_attachments.fppc_disk_device.volume_attachments[1].port
  }
}

locals {
  repo_script     = "/tmp/01_repo_setup.sh"
  u01_script      = "/tmp/02_u01_setup.sh"
  asmdisk_script      = "/tmp/03_asmdisk_setup.sh"
}



# ---------------------------------------------------------
# Data: last image build for 7.8
# ---------------------------------------------------------
data "oci_core_images" "vm_images" {
    compartment_id             = var.compartment_id
    operating_system           = "Oracle Linux"
    operating_system_version   = "7.8"
    sort_by                    = "TIMECREATED"
    sort_order                 = "DESC"
}


# ---------------------------------------------------------
# data: attached volumes
# it requires the creation of the attachment first.
# it's used to get the variables for the setup script that partitions the volume for the creation of /u01 and the asmdisk
# ---------------------------------------------------------
data "oci_core_volume_attachments" "fppc_disk_device" {
    depends_on = [oci_core_instance.fppc_vm, oci_core_volume_attachment.fppc_volume_attachment, oci_core_volume.fppc_disk]

    compartment_id  = var.compartment_id
    instance_id     = oci_core_instance.fppc_vm.id
#    volume_id       = oci_core_volume.fppc_disk.id
}


# ---------------------------------------------------------
# instance creation
# ---------------------------------------------------------
resource "oci_core_instance" "fppc_vm" {
    availability_domain = var.availability_domain
    compartment_id      = var.compartment_id
    shape               = var.vm_shape
    display_name        = var.fppc_name

    source_details {
        source_id = data.oci_core_images.vm_images.images[0].id
        source_type = "image"
        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    }

    shape_config {
        ocpus = var.instance_ocpus
        memory_in_gbs = var.instance_memgb
    }

    create_vnic_details {
        assign_public_ip = true
        subnet_id               = var.subnet_id
        display_name            = "${var.fppc_name}-public-vnic"
        hostname_label          = var.fppc_name
    }

    metadata = {
        ssh_authorized_keys = var.ssh_public_key
	user_data = base64encode(file("../scripts/bootstrap.sh"))
    } 
}

# ---------------------------------------------------------
# block volume creation for u01
# ---------------------------------------------------------
resource "oci_core_volume" "fppc_disk" {
    # volume 0 for u01, volume 1 for ASM
    count=2
    availability_domain = var.availability_domain
    compartment_id      = var.compartment_id
    display_name = format("%s-disk%02d",var.fppc_name, count.index+1)
    size_in_gbs = var.fppc_disk_size
}

# ---------------------------------------------------------
# attachment of the volume to the instance
# ---------------------------------------------------------
resource "oci_core_volume_attachment" "fppc_volume_attachment" {
    count=2
    attachment_type = "iscsi"
    instance_id = oci_core_instance.fppc_vm.id
    volume_id = oci_core_volume.fppc_disk[count.index].id
    is_read_only = false
    is_shareable = true
}


resource "null_resource" "fppc_setup" {
  depends_on = [oci_core_instance.fppc_vm, oci_core_volume_attachment.fppc_volume_attachment, oci_core_volume.fppc_disk]

  provisioner "file" {
    content     = data.template_file.repo_setup.rendered
    destination = local.repo_script
    connection  {
      type        = "ssh"
      host        = oci_core_instance.fppc_vm.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = file(var.opc_private_key_path)

    }
  }
  provisioner "file" {
    content     = data.template_file.u01_setup.rendered
    destination = local.u01_script
    connection  {
      type        = "ssh"
      host        = oci_core_instance.fppc_vm.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = file(var.opc_private_key_path)

    }
  }

  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = oci_core_instance.fppc_vm.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = file(var.opc_private_key_path)
    }

    inline = [
       "chmod +x ${local.repo_script}",
       "sudo ${local.repo_script}",
       "chmod +x ${local.u01_script}",
       "sudo ${local.u01_script}",
    ]

   }

}




resource "null_resource" "fppc_asm_setup" {
  depends_on = [oci_core_instance.fppc_vm, oci_core_volume_attachment.fppc_volume_attachment, oci_core_volume.fppc_disk, null_resource.fppc_setup]

  provisioner "file" {
    content     = data.template_file.asmdisk_setup.rendered
    destination = local.asmdisk_script
    connection  {
      type        = "ssh"
      host        = oci_core_instance.fppc_vm.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = file(var.opc_private_key_path)

    }
  }

  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = oci_core_instance.fppc_vm.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = file(var.opc_private_key_path)
    }

    inline = [
       "chmod +x ${local.asmdisk_script}",
       "sudo ${local.asmdisk_script}",
    ]

   }

}
