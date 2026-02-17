variable "mssql_sa_password" {
  description = "SA password for the MSSQL container"
  type        = string
  sensitive   = true
}

variable "windows_ipv4_address" {
  description = "Static IPv4 address for the Windows VM on incusbr0"
  type        = string
  default     = "192.168.0.240"
}
