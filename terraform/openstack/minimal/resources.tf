resource "openstack_compute_secgroup_v2" "timon" {
  name        = "${var.prefix}-secgroup"
  description = "minimal security group"

  rule {
    cidr        = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port   = 1
    to_port     = 65535
  }

  rule {
    cidr        = "0.0.0.0/0"
    ip_protocol = "udp"
    from_port   = 1
    to_port     = 65535
  }

  rule {
    cidr        = "0.0.0.0/0"
    ip_protocol = "icmp"
    from_port   = -1
    to_port     = -1
  }
}

resource "openstack_networking_network_v2" "timon" {
  name = "${var.prefix}-network"
}

resource "openstack_networking_subnet_v2" "timon" {
  name            = "${var.prefix}-subnet"
  network_id      = openstack_networking_network_v2.timon.id
  cidr            = "192.168.16.0/24"
  ip_version      = 4

  allocation_pool {
    start = "192.168.16.200"
    end   = "192.168.16.250"
  }
}

resource "openstack_compute_keypair_v2" "timon" {
  name = "${var.prefix}-keypair"
}

resource "openstack_compute_instance_v2" "timon" {
  name            = "${var.prefix}-instance"
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.timon.name
  security_groups = ["default", "${var.prefix}-secgroup"]
  depends_on      = [
    openstack_networking_subnet_v2.timon,
    openstack_compute_secgroup_v2.timon,
    openstack_compute_keypair_v2.timon
  ]
  network {
    name = "${var.prefix}-network"
  }
}

resource "openstack_networking_floatingip_v2" "timon" {
  pool       = var.public
  depends_on = [openstack_networking_router_interface_v2.router_interface]
}

resource "openstack_compute_floatingip_associate_v2" "timon" {
  floating_ip = openstack_networking_floatingip_v2.timon.address
  instance_id = "${openstack_compute_instance_v2.timon.id}"
  depends_on  = [openstack_compute_instance_v2.timon]
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.prefix}-router"
  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.timon.id
}
