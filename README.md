# Terraform OCI Stack for testing Oracle Fleet Patching and Provisioning

## What this stack is for
* For getting acquainted with FPP in a segregated, sandbox environment
* For operating uniquely on the target provisioned by this lab
* **Do not use FPP in the Cloud to patch your Cloud Database Services, this is not supported!**

There is a Vagrant project for FPP to let you play in a virtual environment on-premises, it works with Virtualbox or KVM.
* [Official OracleFPP Vagrant project ](https://github.com/oracle/vagrant-projects/tree/master/OracleFPP)
* [Fork by @brokedba](https://github.com/brokedba/OracleFPP) that includes additional labs (also read @brokedba blog post [here](https://eclipsys.ca/my-vagrant-fork-of-oracle-fleet-patching-and-provisioning-fpp/) and an additional one by @solifugo [here](https://project42.site/oracle-fleet-patching-and-provisioning-using-brokedba-vagrant-fork/))

If you do not have the capacity on-premises and you would like to test it in the Oracle Cloud Infrastructure, then you can leverage this stack to set up a lab quickly.


## What this stack is NOT for
* **Do not use FPP in the Cloud to patch your Cloud Database Services, this is not supported!**
* Do not use it to provision a production FPP in the Cloud, the current FPP versions (19c, 21c) are meant to be set up and used on-premises only. This stack is an exception provided for educational purposes only.

## Description
This Terraform stack configures an Oracle FPP Server and Target in a pre-existing compartment in your Tenancy (either paid or Free Trial, but it does not work with Always-Free).

The default VCN and subnet IP ranges are `10.0.0.0/16` and `10.0.0.0/24`. You can modify the variables in `main.tf`, everything should adapt dynamically, however I have not tested it with different addresses.

The **FPP Server** uses a DBCS VM single-instance deployment to leverage the full Grid Infrastructure stack that is required by FPP. On top of that the stack configures the MGMTDB database, and configures and start the FPP Server. The GI and DB version is `19.10.0.0`.

The **FPP Target** is a normal compute instance, on which the stack adds two disks for ASM and `/u01` filesystem. Some additional steps are also executed, like setting up some pre-requirements to host the provisioned database, etc. The image used is the last build of `Oracle Linux 7.9`. Beware that new versions might appear and old one disappear, so you might need to adapt the version number in `modules/fppclient/fppclient.tf`.

At the end of the apply, the output will show the public IP addresses for the FPP Server and FPP target. You connect as `opc`using the private key corresponding to the public key passed as variable.

If you are unsure about how to test FPP, you can follow the instructions of the FPP Livelab (which have been written based on this Terraform stack). You can find them here: https://lcaldara-oracle.github.io/learning-library/data-management-library/database/fpp/workshops/livelabs/index.html?lab=lab-1-get-acquainted-environment-the

## How to run this Terraform Stack

* Clone the repository
```
$ git clone https://github.com/ludovicocaldara/tf-fpp.git
Cloning into 'tf-fpp'...
remote: Enumerating objects: 124, done.
remote: Counting objects: 100% (124/124), done.
remote: Compressing objects: 100% (71/71), done.
remote: Total 124 (delta 70), reused 104 (delta 50), pack-reused 0
Receiving objects: 100% (124/124), 32.14 KiB | 1.79 MiB/s, done.
Resolving deltas: 100% (70/70), done.
$ cd tf-fpp
```

* Prepare a SSH key pair or make sure that you have one already.
```
$ ssh-keygen -t rsa -b 2048 -f ssh_key
```

* Prepare the file `override.tf` with the required variables for the OCI provider (replace with YOUR values):
```
variable "ociCompartmentOcid" {
  default = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaoaaaaaaaaaaaaaaaaaaaaa"
}
variable "ociTenancyOcid" {
  default = "ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
variable "ociRegionIdentifier" {
  default = "uk-london-1"
}
variable "availability_domain_name" {
  default = "OUGC:UK-LONDON-1-AD-1"
}
variable "ociUserOcid" {
  default = "ocid1.user.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
variable "private_key_path" {
  description = "The OCI API keys for your user"
  default = "~/oci.pem"
}
variable "fingerprint" {
  description = "The OCI API fingerprint for your user"
  default = "de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef"
}
variable "ssh_public_key" {
        description ="Content of your ssh_key.pub"
        default = "ssh-rsa [...]"
}
variable "ssh_private_key" {
        description ="Content of your ssh_key, replace carriage returns with \n"
        default = "-----BEGIN RSA PRIVATE KEY-----\nabcd[...]efgh==\n-----END RSA PRIVATE KEY-----\n"
}
provider "oci" {
  tenancy_ocid = var.ociTenancyOcid
  user_ocid = var.ociUserOcid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  region = var.ociRegionIdentifier
}
```

* Run the Terraform stack
```
$ terraform init
$ terraform validate
$ terraform plan
$ terraform apply
```

The apply process takes ~90 minutes.
At the end, the stack shows the IPs of the FPP Server and Target that you can use to connect as `opc` with your private key.


## Terraform Resources
The following resources are configured:
* Networking
 * `oci_core_vcn`
 * `oci_core_internet_gateway`
 * `oci_core_route_table`
 * `oci_core_security_list`
 * `oci_core_network_security_group`
 * `oci_core_subnet`
* FPP Server
 * `oci_database_db_system`
 * `null_resource` (for remote-exec provisioners)
* FPP Target
 * `oci_core_instance`
 * `oci_core_volume` (2x: one for the ASM disk, one for /u01)
 * `oci_core_attachment` (2x: one for the ASM disk, one for /u01)
 * `null_resource` (for remote-exec provisioners)

There are a few variables used by the fppclient and fppserver modules, however I have not implemented the possibility to modify them, as this stack is just for educational purpose.

This stack configures the FPP Client with a shape `VM.Standard.E3.Flex`, 2 OCPUs, 32GB of RAM. Make sure that you have enough quota for that. You can alternatively switch to `VM.Standard2.2` by modifying the code. The FPP Server uses a DB System `VM.Standard2.2`, again, make sure that you have enough resources in your quota/tenancy for that.

## Required Security Policies
The following policies are required to apply the stack in OCI:
* `Allow group {GroupName} to manage instance-family in compartment {CompartmentName}`
* `Allow group {GroupName} to manage volume-family in compartment {CompartmentName}`
* `Allow group {GroupName} to manage database-family in compartment {CompartmentName}`
* `Allow group {GroupName} to manage virtual-network-family in compartment {CompartmentName}`

This list should also work (the permissions are more restrictive). However, I have not tested it:
* `Allow group {GroupName} to manage instance-family in compartment {CompartmentName}`
* `Allow group {GroupName} to inspect databases in compartment {CompartmentName}`
* `Allow group {GroupName} to inspect db-homes in compartment {CompartmentName}`
* `Allow group {GroupName} to manage db-systems in compartment {CompartmentName`
* `Allow group {GroupName} to manage virtual-network-family in compartment {CompartmentName}`
* `Allow group {GroupName} to manage volumes in compartment {CompartmentName}`
* `Allow group {GroupName} to manage volume-attachments in compartment {CompartmentName}`

## Other security aspects
The passwords for the FFP Server cloud-provisioned database and the FPP client opc user are in clear text in the code.
**Do not enable password-based SSH authentication to your machine until you change the password** and **do not open ports from the Internet** except the key-based SSH that is there by default.
