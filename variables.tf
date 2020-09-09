variable "location" {}

variable "client_id" {}

variable "client_secret" {}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "ssh_key" {}

variable "kubernetes_version" {
    default = "1.16.13"
}