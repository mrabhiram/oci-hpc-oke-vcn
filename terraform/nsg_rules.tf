# Copyright (c) 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  bastion_nsg_id  = var.create_bastion_subnet ? oci_core_network_security_group.bastion_nsg[0].id : null
  operator_nsg_id = var.create_operator_subnet ? oci_core_network_security_group.operator_nsg[0].id : null
  int_lb_nsg_id   = oci_core_network_security_group.int_lb_nsg.id
  pub_lb_nsg_id   = var.create_public_subnets ? oci_core_network_security_group.pub_lb_nsg[0].id : null
  cp_nsg_id       = oci_core_network_security_group.cp_nsg.id
  workers_nsg_id  = oci_core_network_security_group.workers_nsg.id
  pods_nsg_id     = oci_core_network_security_group.pods_nsg.id
  fss_nsg_id      = var.create_fss_subnet ? oci_core_network_security_group.fss_nsg[0].id : null
}

resource "oci_core_network_security_group_security_rule" "cp_to_cp_tcp_6443" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.cp_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress for Kubernetes control plane inter-communication"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_from_cp_tcp_6443" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.cp_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress for Kubernetes control plane inter-communication"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_to_workers_tcp_10250" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from OKE control plane to Kubelet on worker nodes"

  tcp_options {
    destination_port_range {
      min = 10250
      max = 10250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_to_workers_icmp" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "EGRESS"
  protocol                  = "1"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ICMP egress for path discovery to worker nodes"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "cp_from_workers_tcp_6443" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.workers_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to kube-apiserver from worker nodes"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_from_pods_tcp_6443" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.pods_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to kube-apiserver from pods"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_to_pods_tcp" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.pods_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from OKE control plane to pods"
}

resource "oci_core_network_security_group_security_rule" "cp_to_workers_tcp" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from OKE control plane to worker nodes"

  tcp_options {
    destination_port_range {
      min = 12250
      max = 12250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_to_services_tcp" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "all-iad-services-in-oracle-services-network"
  destination_type          = "SERVICE_CIDR_BLOCK"
  description               = "Allow TCP egress from OKE control plane to OCI services"
}

resource "oci_core_network_security_group_security_rule" "cp_from_workers_tcp_12250" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.workers_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to OKE control plane from worker nodes"

  tcp_options {
    destination_port_range {
      min = 12250
      max = 12250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_from_pods_tcp_12250" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.pods_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to OKE control plane from pods"

  tcp_options {
    destination_port_range {
      min = 12250
      max = 12250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_from_internet_tcp_6443" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow TCP ingress to kube-apiserver from 0.0.0.0/0"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cp_from_workers_icmp" {
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = local.workers_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ICMP ingress for path discovery from worker nodes"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "workers_to_workers_all" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL egress from workers to other workers"
}

resource "oci_core_network_security_group_security_rule" "workers_from_workers_all" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.workers_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL ingress to workers from other workers"
}

resource "oci_core_network_security_group_security_rule" "workers_to_pods_all" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = local.pods_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL egress from workers to pods"
}

resource "oci_core_network_security_group_security_rule" "workers_from_pods_all" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.pods_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL ingress to workers from pods"
}

resource "oci_core_network_security_group_security_rule" "workers_to_cp_tcp_6443" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.cp_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from workers to Kubernetes API server"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_to_cp_tcp_12250" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.cp_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from workers to OKE control plane"

  tcp_options {
    destination_port_range {
      min = 12250
      max = 12250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_to_cp_tcp_10250" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.cp_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress to OKE control plane from workers for health check"

  tcp_options {
    destination_port_range {
      min = 10250
      max = 10250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_cp_all" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.cp_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL ingress to workers from Kubernetes control plane for webhooks served by workers"
}

resource "oci_core_network_security_group_security_rule" "workers_to_internet_all" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow ALL egress from workers to internet"
}

resource "oci_core_network_security_group_security_rule" "workers_to_services_tcp" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "all-iad-services-in-oracle-services-network"
  destination_type          = "SERVICE_CIDR_BLOCK"
  description               = "Allow TCP egress from workers to OCI Services"
}

resource "oci_core_network_security_group_security_rule" "workers_to_internet_icmp" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "EGRESS"
  protocol                  = "1"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow ICMP egress from workers for path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_internet_icmp" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow ICMP ingress to workers for path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_pub_lb_tcp_health" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.pub_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress from public load balancers to worker nodes for health checks"

  tcp_options {
    destination_port_range {
      min = 10256
      max = 10256
    }
  }
}


resource "oci_core_network_security_group_security_rule" "workers_from_int_lb_tcp_health" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.int_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress from internal load balancers to worker nodes for health checks"

  tcp_options {
    destination_port_range {
      min = 10256
      max = 10256
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_int_lb_tcp_nodeport" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.int_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to workers from internal load balancers"

  tcp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_int_lb_udp_nodeport" {
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = local.int_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow UDP ingress to workers from internal load balancers"

  udp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_pub_lb_udp_nodeport" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = local.pub_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow UDP ingress to workers from public load balancers"

  udp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_pub_lb_tcp_nodeport" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.pub_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to workers from public load balancers"

  tcp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pods_to_pods_all" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = local.pods_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL egress from pods to other pods"
}

resource "oci_core_network_security_group_security_rule" "pods_from_pods_all" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.pods_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL ingress to pods from other pods"
}

resource "oci_core_network_security_group_security_rule" "pods_to_workers_all" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL egress from pods for cross-node pod communication when using NodePorts or hostNetwork: true"
}

resource "oci_core_network_security_group_security_rule" "pods_from_workers_all" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.workers_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL ingress to pods for cross-node pod communication when using NodePorts or hostNetwork: true"
}

resource "oci_core_network_security_group_security_rule" "pods_from_cp_all" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.cp_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow ALL ingress to pods from Kubernetes control plane for webhooks served by pods"
}

resource "oci_core_network_security_group_security_rule" "pods_to_internet_all" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow ALL egress from pods to internet"
}

resource "oci_core_network_security_group_security_rule" "pods_to_services_tcp" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "all-iad-services-in-oracle-services-network"
  destination_type          = "SERVICE_CIDR_BLOCK"
  description               = "Allow TCP egress from pods to OCI Services"
}

resource "oci_core_network_security_group_security_rule" "pods_to_internet_icmp" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "EGRESS"
  protocol                  = "1"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow ICMP egress from pods for path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "pods_from_internet_icmp" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow ICMP ingress to pods for path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "pods_to_cp_tcp_6443" {
  network_security_group_id = local.pods_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.cp_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from pods to Kubernetes API server"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_from_internet_tcp_80" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.pub_lb_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow TCP ingress from anywhere to HTTP port"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_from_internet_tcp_443" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.pub_lb_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow TCP ingress from anywhere to HTTPS port"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_to_workers_tcp_health" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.pub_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from public load balancers to worker nodes for health checks"

  tcp_options {
    destination_port_range {
      min = 10256
      max = 10256
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_to_workers_tcp_nodeport" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.pub_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from public load balancers to workers nodes for NodePort traffic"

  tcp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_to_workers_icmp" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.pub_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "1"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ICMP egress from public load balancers to worker nodes for path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_to_workers_udp_nodeport" {
  count                     = var.create_public_subnets ? 1 : 0
  network_security_group_id = local.pub_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "17"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow UDP egress from public load balancers to workers nodes for NodePort traffic"

  udp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "int_lb_from_vcn_all" {
  network_security_group_id = local.int_lb_nsg_id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = local.vcn_cidr
  source_type               = "CIDR_BLOCK"
  description               = "Allow TCP ingress to internal load balancers from internal VCN/DRG"
}

resource "oci_core_network_security_group_security_rule" "int_lb_to_workers_tcp_health" {
  network_security_group_id = local.int_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from internal load balancers to worker nodes for health checks"

  tcp_options {
    destination_port_range {
      min = 10256
      max = 10256
    }
  }
}

resource "oci_core_network_security_group_security_rule" "int_lb_to_workers_tcp_nodeport" {
  network_security_group_id = local.int_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from internal load balancers to workers for Node Ports"

  tcp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "int_lb_to_workers_udp_nodeport" {
  network_security_group_id = local.int_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "17"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow UDP egress from internal load balancers to workers for Node Ports"

  udp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_network_security_group_security_rule" "int_lb_to_workers_icmp" {
  network_security_group_id = local.int_lb_nsg_id
  direction                 = "EGRESS"
  protocol                  = "1"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow ICMP egress from internal load balancers to worker nodes for path discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_from_internet_ssh" {
  count                     = var.create_bastion_subnet ? 1 : 0
  network_security_group_id = local.bastion_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow SSH ingress to bastion from 0.0.0.0/0"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_to_workers_ssh" {
  count                     = var.create_bastion_subnet ? 1 : 0
  network_security_group_id = local.bastion_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.workers_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow SSH egress from bastion to workers"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_from_bastion_ssh" {
  count                     = var.create_bastion_subnet ? 1 : 0
  network_security_group_id = local.workers_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.bastion_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow SSH ingress to workers from bastion"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_to_cp_tcp_6443" {
  count                     = var.create_bastion_subnet ? 1 : 0
  network_security_group_id = local.bastion_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = local.cp_nsg_id
  destination_type          = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP egress from bastion to cluster endpoint"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_to_services_tcp" {
  count                     = var.create_bastion_subnet ? 1 : 0
  network_security_group_id = local.bastion_nsg_id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "all-iad-services-in-oracle-services-network"
  destination_type          = "SERVICE_CIDR_BLOCK"
  description               = "Allow TCP egress from bastion to OCI services"
}

resource "oci_core_network_security_group_security_rule" "cp_from_bastion_tcp_6443" {
  count                     = var.create_bastion_subnet ? 1 : 0
  network_security_group_id = local.cp_nsg_id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.bastion_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow TCP ingress to kube-apiserver from bastion host"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}
