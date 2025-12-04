# Copyright (c) 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  vcn_cidr = local.vcn_cidrs[0]
}

resource "oci_core_subnet" "bastion" {
  count = var.create_bastion_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 13, 1)

  display_name               = format("bastion-%s", local.state_id)
  dns_label                  = var.assign_dns ? "bastion" : null
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false

  route_table_id = module.vcn.ig_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "bastion"
    },
    var.tags
  )
}

resource "oci_core_subnet" "operator" {
  count = var.create_operator_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 13, 2)

  display_name               = format("operator-%s", local.state_id)
  dns_label                  = var.assign_dns ? "operator" : null
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false

  route_table_id = module.vcn.ig_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "operator"
    },
    var.tags
  )
}

resource "oci_core_subnet" "int_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 11, 1)

  display_name               = format("int_lb-%s", local.state_id)
  dns_label                  = var.assign_dns ? "intlb" : null
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true

  route_table_id = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.int_lb.id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "int_lb"
    },
    var.tags
  )
}

resource "oci_core_subnet" "pub_lb" {
  count = var.create_public_subnets ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 11, 2)

  display_name               = format("pub_lb-%s", local.state_id)
  dns_label                  = var.assign_dns ? "publb" : null
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false

  route_table_id = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.pub_lb[0].id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "pub_lb"
    },
    var.tags
  )
}

resource "oci_core_subnet" "cp" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 13, 0)

  display_name               = format("cp-%s", local.state_id)
  dns_label                  = var.assign_dns ? "cp" : null
  prohibit_public_ip_on_vnic = !var.control_plane_is_public
  prohibit_internet_ingress  = !var.control_plane_is_public

  route_table_id = var.control_plane_is_public ? module.vcn.ig_route_id : module.vcn.nat_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "control_plane"
    },
    var.tags
  )
}

resource "oci_core_subnet" "workers" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 4, 2)

  display_name               = format("workers-%s", local.state_id)
  dns_label                  = var.assign_dns ? "workers" : null
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true

  route_table_id = module.vcn.nat_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "workers"
    },
    var.tags
  )
}

resource "oci_core_subnet" "pods" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 2, 2)

  display_name               = format("pods-%s", local.state_id)
  dns_label                  = var.assign_dns ? "pods" : null
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true

  route_table_id = module.vcn.nat_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "pods"
    },
    var.tags
  )
}

resource "oci_core_subnet" "fss" {
  count = var.create_fss_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 11, 3)

  display_name               = format("fss-%s", local.state_id)
  dns_label                  = var.assign_dns ? "fss" : null
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true

  route_table_id = module.vcn.nat_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "fss"
    },
    var.tags
  )
}

resource "oci_core_subnet" "lustre" {
  count = var.create_lustre_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = cidrsubnet(local.vcn_cidr, 7, 1)

  display_name               = format("lustre-%s", local.state_id)
  dns_label                  = var.assign_dns ? "lustre" : null
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true

  route_table_id = module.vcn.nat_route_id
  security_list_ids = [module.vcn.default_security_list_id]

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "lustre"
    },
    var.tags
  )
}
