# OCI VCN for OKE GPU Workloads

This Terraform configuration creates a VCN (Virtual Cloud Network) designed for Oracle Kubernetes Engine (OKE) clusters running GPU workloads. The network topology replicates the production-tested configuration from the [OCI HPC OKE stack](https://github.com/oracle-quickstart/oci-hpc-oke), providing a secure and scalable foundation for deploying containerized GPU applications.

## Network Architecture

The VCN includes six subnets organized by function:

- **Control Plane Subnet** - Private subnet for OKE control plane endpoints
- **Worker Node Subnet** - Private subnet for Kubernetes worker nodes
- **Pod Subnet** - Private subnet for pod IP allocation
- **Internal Load Balancer Subnet** - Private subnet for internal load balancers
- **Public Load Balancer Subnet** - Public subnet for internet-facing load balancers
- **Bastion Subnet** - Public subnet for bastion host access

The network uses Network Security Groups (NSGs) for security policy enforcement rather than security lists. This provides more granular control and better scalability for Kubernetes workloads.

## Deploying the VCN

You can deploy this VCN configuration using either the command line with Terraform or through the OCI Resource Manager console interface.

### Prerequisites

The following items are required before deployment:

- An OCI tenancy with appropriate permissions to create VCN resources
- A compartment where the VCN will be created
- Terraform version 1.2.0 or later (for command line deployment)
- OCI CLI configured with valid credentials (for command line deployment)

### Required Policies

Ensure you have the necessary IAM policies to create and manage VCN resources. At minimum, you need:

```
Allow group <your-group> to manage virtual-network-family in compartment <your-compartment>
```

For more information, see the [VCN IAM policies documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/networkingpolicyreference.htm).

### Deploying with Terraform

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd oci-hpc-oke-vcn/terraform
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Review and deploy**

   ```bash
   terraform plan \
     -var compartment_ocid=ocid1.compartment.oc1..aaa... \
     -var tenancy_ocid=ocid1.tenancy.oc1..aaa... \
     -var region=us-ashburn-1
   
   terraform apply \
     -var compartment_ocid=ocid1.compartment.oc1..aaa... \
     -var tenancy_ocid=ocid1.tenancy.oc1..aaa... \
     -var region=us-ashburn-1
   ```

   Or create a `terraform.tfvars` file with your values:

   ```hcl
   compartment_ocid = "ocid1.compartment.oc1..aaa..."
   tenancy_ocid     = "ocid1.tenancy.oc1..aaa..."
   region           = "us-ashburn-1"
   ```

4. **Retrieve the outputs**

   After deployment completes, you can view the created resource IDs:

   ```bash
   terraform output
   ```

### Deploying with OCI Resource Manager

1. **Create a stack ZIP file**

   Package the Terraform configuration files:

   ```bash
   cd terraform
   zip -r ../oci-vcn-stack.zip *.tf *.yaml
   ```

2. **Create a stack in OCI Console**

   - Navigate to **Developer Services** > **Resource Manager** > **Stacks**
   - Click **Create Stack**
   - Select **My Configuration** and upload the ZIP file
   - Choose the compartment for the stack
   - Click **Next**

3. **Configure variables**

   On the Configure Variables screen, provide:
   - Target compartment OCID for VCN resources
   - VCN name (optional, defaults to oke-gpu-quickstart)
   - VCN CIDR block (optional, defaults to 10.0.0.0/16)

4. **Create and apply the stack**

   - Click **Next** then **Create**
   - Run **Plan** to review changes
   - Run **Apply** to create the resources

## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `compartment_ocid` | Compartment OCID for VCN resources | - | Yes |
| `tenancy_ocid` | Tenancy OCID | - | Yes |
| `region` | OCI region identifier | - | Yes |
| `home_region` | Home region for the tenancy | null | No |
| `vcn_name` | Base name for the VCN | `oke-gpu-quickstart` | No |
| `vcn_cidrs` | CIDR block for the VCN | `10.0.0.0/16` | No |
| `create_public_subnets` | Create public subnets and internet gateway | `true` | No |

## Network Security

Security is enforced through Network Security Groups (NSGs) rather than security lists. The configuration creates six NSGs corresponding to each subnet:

- **Bastion NSG** - Controls SSH access to the bastion host and outbound connectivity to worker nodes and control plane
- **Control Plane NSG** - Manages Kubernetes API server access and control plane to worker node communication
- **Worker NSG** - Handles all worker node traffic including inter-node communication, pod networking, and load balancer connections
- **Pod NSG** - Controls pod-to-pod traffic and pod access to the Kubernetes API server
- **Internal Load Balancer NSG** - Manages internal load balancer connectivity to worker nodes
- **Public Load Balancer NSG** - Controls ingress HTTP/HTTPS traffic and egress to worker nodes

The default security list is locked down with all rules removed. All network security is managed through the NSGs, which provides better visibility and control for Kubernetes workloads.

## Outputs

After successful deployment, the following information is available:

- `vcn_id` - OCID of the VCN
- `vcn_name` - Full name of the VCN including generated suffix
- `vcn_cidr_blocks` - CIDR blocks assigned to the VCN
- `internet_gateway_id` - OCID of the internet gateway
- `nat_gateway_id` - OCID of the NAT gateway
- `service_gateway_id` - OCID of the service gateway
- `ig_route_table_id` - OCID of the internet gateway route table
- `nat_route_table_id` - OCID of the NAT gateway route table
- `bastion_subnet_id` - OCID of the bastion subnet
- `cp_subnet_id` - OCID of the control plane subnet
- `workers_subnet_id` - OCID of the worker nodes subnet
- `pods_subnet_id` - OCID of the pod subnet
- `int_lb_subnet_id` - OCID of the internal load balancer subnet
- `pub_lb_subnet_id` - OCID of the public load balancer subnet
- `bastion_nsg_id` - OCID of the bastion NSG
- `cp_nsg_id` - OCID of the control plane NSG
- `workers_nsg_id` - OCID of the worker nodes NSG
- `pods_nsg_id` - OCID of the pod NSG
- `int_lb_nsg_id` - OCID of the internal load balancer NSG
- `pub_lb_nsg_id` - OCID of the public load balancer NSG

## Cleanup

To remove all resources created by this configuration:

### Using Terraform

```bash
terraform destroy
```

### Using OCI Resource Manager

Navigate to your stack in the OCI Console and click **Destroy** under the **Terraform Actions** menu.

## Notes

- The VCN name automatically receives an 8-character random suffix to prevent naming conflicts
- NAT and service gateways are always created to provide private subnet connectivity
- Public subnets can be disabled by setting `create_public_subnets` to false

## Related Resources

- [OCI HPC OKE Stack](https://github.com/oracle-quickstart/oci-hpc-oke) - Complete OKE cluster deployment for GPU workloads with RDMA support
- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm) - Oracle Kubernetes Engine product documentation
- [VCN Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm) - Oracle Cloud Infrastructure networking concepts
