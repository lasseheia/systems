variable "mssql_sa_password" {
  description = "SA password for the MSSQL container"
  type        = string
  sensitive   = true
}

variable "haos_ipv4_address" {
  description = "Static IPv4 address for the Home Assistant OS VM on incusbr0"
  type        = string
  default     = "192.168.0.171"
}

variable "kubernetes_ipv4_address" {
  description = "Static IPv4 address for the Kubernetes VM on incusbr0"
  type        = string
  default     = "192.168.0.131"
}

variable "eclipse_mosquitto_ipv4_address" {
  description = "Static IPv4 address for the Eclipse Mosquitto container on incusbr0"
  type        = string
  default     = "192.168.0.229"
}

variable "zigbee2mqtt_ipv4_address" {
  description = "Static IPv4 address for the Zigbee2MQTT container on incusbr0"
  type        = string
  default     = "192.168.0.172"
}

variable "mssql_ipv4_address" {
  description = "Static IPv4 address for the MSSQL container on incusbr0"
  type        = string
  default     = "192.168.0.51"
}

variable "grafana_ipv4_address" {
  description = "Static IPv4 address for the Grafana container on incusbr0"
  type        = string
  default     = "192.168.0.215"
}

variable "windows_ipv4_address" {
  description = "Static IPv4 address for the Windows VM on incusbr0"
  type        = string
  default     = "192.168.0.240"
}
