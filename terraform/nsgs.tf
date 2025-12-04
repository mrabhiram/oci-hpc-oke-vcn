# Copyright (c) 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "bastion_nsg" {
  count = var.create_bastion_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("bastion-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "bastion"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "operator_nsg" {
  count = var.create_operator_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("operator-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "operator"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "int_lb_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("int_lb-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "int_lb"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "pub_lb_nsg" {
  count = var.create_public_subnets ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("pub_lb-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "pub_lb"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "cp_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("cp-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "control_plane"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "workers_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("workers-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "workers"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "pods_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("pods-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "pods"
    },
    var.tags
  )
}

resource "oci_core_network_security_group" "fss_nsg" {
  count = var.create_fss_subnet ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = format("fss-%s", local.state_id)

  freeform_tags = merge(
    {
      "state_id" = local.state_id,
      "role"     = "fss"
    },
    var.tags
  )
}
