#!/bin/bash
 
yum install -y python-oci-cli
systemctl enable ocid.service
systemctl start ocid.service
systemctl status ocid.service
