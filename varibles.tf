variable "subscription_id" {
  description = "The Azure subscription ID where resources will be created."
  type        = string
  default     = "<YOUR SUB ID>" # change it to your subscription ID
  sensitive   = true

}

variable "admin_password" {
  description = "The admin user password for the linux VM."
  type        = string
  sensitive   = true
  default     = "<ADMIN PASSWORD>" # change it to your own password

}

variable "public_key" {
  description = "The public SSH key for the linux VM."
  type        = string
  default     = "<PATH TO PUB KEY>" # change it to your own public key path
  sensitive   = true

}

variable "GF_SECURITY_ADMIN_PASSWORD" {
  description = "The admin password for Grafana."
  type        = string
  sensitive   = true
  default     = "<GRAFANA PASSWORD>" # change it to your own password

}

variable "OPENWEATHER_API_KEY" {
  description = "The API key for OpenWeather."
  type        = string
  sensitive   = true
  default     = "<API KEY>" # change it

}