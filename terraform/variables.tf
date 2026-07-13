variable "os_username" {
  default = "adrian"
}

variable "os_password" {
  sensitive = true
}

variable "os_project_name" {
  default = "stagiaires-ete-2026"
}

variable "instance_name" {
  default = "pfe-mern-server-kawther"
}

variable "image_name" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "admin_ssh_keys" {
  type    = list(string)
  default = []
}

variable "routed_subnet_id" {
  description = "ID of the real Hetzner-routed subnet (88.198.101.144/29)"
  type        = string
}