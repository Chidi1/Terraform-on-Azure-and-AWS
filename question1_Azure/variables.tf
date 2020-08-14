variable "client_id" {
   client_id = "d0a3b785-ac64-4934-9d5d-7f7963e00842"
}
variable "client_secret" {
   client_secret = "xxxxxxxxxxx"
}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "teliosdns"
}

variable resource_group_name {
    default = "teliosRG"
}

variable location {
    default = "Central US"
}

variable log_analytics_workspace_name {
    default = "teliosLogAnalyticsWorkspaceName"
}


variable log_analytics_workspace_location {
    default = "eastus"
}

variable log_analytics_workspace_sku {
    default = "PerGB2018"
}