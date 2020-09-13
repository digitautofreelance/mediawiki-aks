variable "location" {}

variable "serviceprinciple_id" {
}

variable "serviceprinciple_key" {
}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "ssh_key" {
}

variable "kubernetes_version" {
    default = "1.16.13"
}
