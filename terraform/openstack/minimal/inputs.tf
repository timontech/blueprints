variable "prefix" {
  type    = string
  default = "timon"
}

variable "provider_cloud" {
  type    = string
  default = "openstack"
}

variable "public" {
  type    = string
  default = "external"
}

variable "image" {
  type    = string
  default = "Ubuntu 20.04"
}

variable "flavor" {
  type    = string
  default = "SCS-1V:4:10"
}
