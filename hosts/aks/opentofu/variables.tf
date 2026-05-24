variable "name" {
  type        = string
  description = "Prefix used to derive AKS resource names."
}

variable "location" {
  type        = string
  description = "Azure region for the AKS deployment."
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "CIDR ranges allowed to reach the AKS API server."
}
