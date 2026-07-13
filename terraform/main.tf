# Keypair
resource "openstack_compute_keypair_v2" "my_key" {
  depends_on = [null_resource.ssh_tunnel]
  name       = "adrian-key"
  public_key = var.admin_ssh_keys[0]
}

# Security Group
resource "openstack_compute_secgroup_v2" "mern_sg" {
  depends_on  = [null_resource.ssh_tunnel]
  name        = "mern-access-adrian-v2"
  description = "MERN stack security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 3000
    to_port     = 3000
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 5000
    to_port     = 5000
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 27017
    to_port     = 27017
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
rule {
  from_port = -1
  to_port = -1
  ip_protocol = "icmp"
  cidr = "0.0.0.0/0"
  }
}
# Volume Cinder
resource "openstack_blockstorage_volume_v3" "adrian_volume" {
  depends_on  = [null_resource.ssh_tunnel]
  name        = "volume-adrian"
  size        = 10  # taille en GB, adapte selon ce qui est disponible
  description = "Volume de stockage pour pfe-mern-server"
}

# VM Instance
resource "openstack_compute_instance_v2" "mern_server" {
  name            = var.instance_name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.my_key.name
  security_groups = [openstack_compute_secgroup_v2.mern_sg.name]

  network {
    name = var.network_name
  }

  user_data = <<-EOF
    #cloud-config
    ssh_authorized_keys:
      - ${join("\n      - ", var.admin_ssh_keys)}
  EOF
}
# Attacher le volume à la VM
resource "openstack_compute_volume_attach_v2" "adrian_volume_attach" {
  instance_id = openstack_compute_instance_v2.mern_server.id
  volume_id   = openstack_blockstorage_volume_v3.adrian_volume.id
}

# Floating IP
resource "openstack_networking_floatingip_v2" "fip" {
  pool      = "public"
  subnet_id = var.routed_subnet_id
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.mern_server.id
}

# SSH Tunnel automatique
resource "null_resource" "ssh_tunnel" {
  provisioner "local-exec" {
    command = <<-EOT
      ssh -f -N \
        -L 5000:10.0.1.10:5000 \
        -L 9696:10.0.1.10:9696 \
        -L 9292:10.0.1.10:9292 \
        -L 8774:10.0.1.10:8774 \
        -L 8776:10.0.1.10:8776 \
        tunnel-ete@195.201.169.165 \
        -o StrictHostKeyChecking=no \
        -o ExitOnForwardFailure=yes
      sleep 3
    EOT
  }
}
