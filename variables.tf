variable "project_prefix" {
  description = "Prefix to be used for all resource names"
  type        = string
  default     = "nc2"
}

variable "vpc1_region" {
  description = "Region for VPC 1"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc2_region" {
  description = "Region for VPC 2"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc1_cidr" {
  description = "CIDR block for VPC 1"
  type        = string
  default     = "10.101.0.0/16"
}

variable "vpc2_cidr" {
  description = "CIDR block for VPC 2"
  type        = string
  default     = "10.102.0.0/16"
}

variable "peering_type" {
  description = "Type of peering to use (vpc or tgw)"
  type        = string
  default     = "vpc"
  validation {
    condition     = contains(["vpc", "tgw"], var.peering_type)
    error_message = "Peering type must be either 'vpc' or 'tgw'"
  }
}

variable "vpc1_az" {
  description = "Availability zone for VPC 1"
  type        = string
  default     = "ap-northeast-1a"
}

variable "vpc2_az" {
  description = "Availability zone for VPC 2"
  type        = string
  default     = "ap-northeast-1c"
} 