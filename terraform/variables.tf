# Copyright (c) 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "compartment_ocid" {
  type        = string
  description = "The compartment OCID where the VCN will be created"
}

variable "tenancy_ocid" {
  type        = string
  description = "The tenancy OCID"
}

variable "region" {
  type        = string
  description = "The OCI region where resources will be created"
}

variable "home_region" {
  type        = string
  default     = null
  description = "The home region for the tenancy"
}

variable "create_vcn" {
  type        = bool
  default     = true
  description = "Whether to create VCN"
}

variable "vcn_display_name" {
  type        = string
  default     = "oke-gpu-quickstart"
  description = "Name of the VCN to create"
}

variable "vcn_name" {
  type        = string
  default     = "oke-gpu-quickstart"
  description = "Name of the VCN to create (alias for vcn_display_name)"
}

variable "vcn_cidrs" {
  type        = string
  default     = "10.140.0.0/16"
  description = "CIDR blocks for the VCN"
}

variable "create_public_subnets" {
  type        = bool
  default     = true
  description = "Whether to create public subnets and internet gateway"
}

variable "subnets_advanced_settings" {
  type        = bool
  default     = false
  description = "Show advanced subnet CIDR configuration options"
}

variable "bastion_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for bastion subnet"
}

variable "operator_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for operator subnet"
}

variable "int_lb_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for internal LB subnet"
}

variable "pub_lb_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for public LB subnet"
}

variable "cp_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for control plane subnet"
}

variable "workers_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for workers subnet"
}

variable "pods_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for pods subnet"
}

variable "fss_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for FSS subnet"
}

variable "lustre_subnet_cidr" {
  type        = string
  default     = null
  description = "Optional custom CIDR for Lustre subnet"
}

variable "assign_dns" {
  type        = bool
  default     = true
  description = "Assign DNS labels to VCN and subnets"
}

variable "lockdown_default_seclist" {
  type        = bool
  default     = true
  description = "Remove all default security list rules"
}

variable "internet_gateway_route_rules" {
  type        = list(map(string))
  default     = null
  description = "Additional internet gateway route rules"
}

variable "nat_gateway_route_rules" {
  type        = list(map(string))
  default     = null
  description = "Additional NAT gateway route rules"
}

variable "nat_gateway_public_ip_id" {
  type        = string
  default     = null
  description = "OCID of reserved public IP for NAT gateway"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Freeform tags to apply to all resources"
}

variable "control_plane_is_public" {
  type        = bool
  default     = false
  description = "Whether to create control plane subnet as public"
}

variable "create_bastion_subnet" {
  type        = bool
  default     = true
  description = "Whether to create bastion subnet"
}

variable "create_operator_subnet" {
  type        = bool
  default     = false
  description = "Whether to create operator subnet"
}

variable "create_fss_subnet" {
  type        = bool
  default     = false
  description = "Whether to create file storage subnet"
}

variable "create_lustre_subnet" {
  type        = bool
  default     = false
  description = "Whether to create lustre storage subnet"
}

variable "create_policies" {
  type        = bool
  default     = false
  description = "Create dynamic group and policies for OKE cluster self-managed nodes"
}
