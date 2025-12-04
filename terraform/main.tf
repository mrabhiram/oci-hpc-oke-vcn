# Copyright (c) 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "random_string" "state_id" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "dns_label" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

locals {
  state_id = random_string.state_id.result
  vcn_name = format("%v-%v", var.vcn_name, local.state_id)
  vcn_cidrs = [for cidr in split(",", var.vcn_cidrs) : trimspace(cidr)]
  
  create_internet_gateway = var.create_public_subnets
  create_nat_gateway      = true
  create_service_gateway  = true
}

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"
  
  compartment_id = var.compartment_ocid

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "network",
    },
    var.tags
  )

  create_internet_gateway = local.create_internet_gateway
  create_nat_gateway      = local.create_nat_gateway
  create_service_gateway  = local.create_service_gateway
  
  internet_gateway_route_rules = var.internet_gateway_route_rules
  nat_gateway_route_rules      = var.nat_gateway_route_rules
  nat_gateway_public_ip_id     = var.nat_gateway_public_ip_id
  
  lockdown_default_seclist = var.lockdown_default_seclist
  
  vcn_cidrs     = local.vcn_cidrs
  vcn_dns_label = var.assign_dns ? random_string.dns_label.result : null
  vcn_name      = local.vcn_name
}
