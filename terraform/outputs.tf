output "vm_floating_ip" {
  value       = openstack_networking_floatingip_v2.fip.address
  description = "Public IP to SSH into the VM"
}

output "vm_internal_ip" {
  value       = openstack_compute_instance_v2.mern_server.access_ip_v4
  description = "Internal IP of the VM"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${openstack_networking_floatingip_v2.fip.address}"
  description = "SSH command to connect to your VM"
}
output "volume_id" {
  value       = openstack_blockstorage_volume_v3.adrian_volume.id
  description = "ID du volume Cinder"
}

output "volume_attachment_device" {
  value       = openstack_compute_volume_attach_v2.adrian_volume_attach.device
  description = "Device path du volume dans la VM (ex: /dev/vdb)"
}
