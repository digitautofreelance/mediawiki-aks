variable "serviceprinciple_id" {
}

variable "serviceprinciple_key" {
}

variable "tenant_id" {
}

variable "subscription_id" {
}

variable "ssh_key" {
}

variable "location" {
}

variable "kubernetes_version" {
    default = "1.16.13"
}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}
