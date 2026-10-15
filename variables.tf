
variable "resource_group_name" {
  description = "Resource group for Sakshi's Windows IIS assignment"
  type        = string
}

variable "location" {
  description = "Azure region for the assignment"
  type        = string
}

variable "vm_size" {
  description = "Azure virtual machine size"
  type        = string
}

variable "admin_username" {
  description = "Windows administrator username"
  type        = string
}

variable "admin_password" {
  description = "Windows administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 10
    error_message = "Use a strong Windows administrator password of at least 14 characters."
  }
}

