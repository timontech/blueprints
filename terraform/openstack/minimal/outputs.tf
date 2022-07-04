output "address" {
  value     = openstack_networking_floatingip_v2.timon.address
}

output "private_key" {
  value     = openstack_compute_keypair_v2.timon.private_key
  sensitive = true
}

resource "local_sensitive_file" "private_key" {
  filename        = "/output/private_key"
  file_permission = "0600"
  content         = openstack_compute_keypair_v2.timon.private_key
}

resource "local_sensitive_file" "address" {
  filename        = "/output/address"
  file_permission = "0600"
  content         = openstack_networking_floatingip_v2.timon.address
}
