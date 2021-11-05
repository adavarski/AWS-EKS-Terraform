/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#---------------------------------------------------------#
# EKS CLUSTER CORE VARIABLES
#---------------------------------------------------------#
#Following fields used in tagging resources and building the name of the cluster
#e.g., eks cluster name will be {tenant}-{environment}-{zone}-{resource}
#---------------------------------------------------------#
org               = "aws"     # Organization Name. Used to tag resources
tenant            = "tarya"  # AWS account name or unique id for tenant
environment       = "preprod" # Environment area eg., preprod or prod
zone              = "dev"     # Environment with in one sub_tenant or business unit
terraform_version = "Terraform v1.0.1"
#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
#---------------------------------------------------------#
#This provides two options Option1 and Option2. You should choose either of one to provide VPC details to the EKS cluster
#Option1: Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#Option2: Provide an existing vpc_id and private_subnet_ids

#---------------------------------------------------------#
# OPTION 1
#---------------------------------------------------------#
create_vpc             = true
enable_private_subnets = true
enable_public_subnets  = true

# Enable or Disable NAT Gateqay and Internet Gateway for Public Subnets
enable_nat_gateway = true
single_nat_gateway = true
create_igw         = true

vpc_cidr_block       = "10.1.0.0/18"
private_subnets_cidr = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
public_subnets_cidr  = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]

# Change this to true when you want to create VPC endpoints for Private subnets
create_vpc_endpoints = true
#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
//create_vpc = false
//vpc_id = "xxxxxx"
//private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
kubernetes_version      = "1.20"
endpoint_private_access = true
endpoint_public_access  = true

# Enable IAM Roles for Service Accounts (IRSA) on the EKS cluster
enable_irsa = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

enable_vpc_cni_addon  = true
vpc_cni_addon_version = "v1.8.0-eksbuild.1"

enable_coredns_addon  = true
coredns_addon_version = "v1.8.3-eksbuild.1"

enable_kube_proxy_addon  = true
kube_proxy_addon_version = "v1.20.4-eksbuild.2"


#---------------------------------------------------------#
# WORKER NODE GROUPS SECTION
# Define the following parameters to create EKS Node groups. If you need to two Node groups then you may need to duplicate the with different instance type
# NOTE: Also ensure Node groups config that you defined below needs to exist in this file <aws-eks-production/source/main.tf>.
#         Comment out the node groups in <aws-eks-production/source/main.tf> file if you are not defining below.
#         This is a limitation at this moment that the change needs ot be done in two places. This will be improved later
#---------------------------------------------------------#
#---------------------------------------------------------#
# MANAGED WORKER NODE INPUT VARIABLES FOR ON DEMAND INSTANCES - Worker Group1
#---------------------------------------------------------#
on_demand_node_group_name = "mg_m5"
on_demand_ami_type        = "AL2_x86_64"
on_demand_disk_size       = 50
on_demand_instance_type   = ["m5.large"]
on_demand_desired_size    = 1
on_demand_max_size        = 2
on_demand_min_size        = 1

#---------------------------------------------------------#
# SELF-MANAGED WINDOWS NODE GROUP (WORKER GROUP)
#---------------------------------------------------------#
# enable_self_managed_nodegroups = true
# enable_windows_support         = true
# self_managed_nodegroup_name    = "ng-windows"

#---------------------------------------------------------#
# Creates a Fargate profile for default namespace
#---------------------------------------------------------#
fargate_profile_namespace = "default"
# Enable logging only when you create a Fargate profile
fargate_fluent_bit_enable = true

#---------------------------------------------------------#
# ENABLE HELM MODULES
# Please note that you may need to download the docker images for each
#          helm module and push it to ECR if you create fully private EKS Clusters with no access to internet to fetch docker images.
#          README with instructions available in each HELM module under helm/
#---------------------------------------------------------#
# Enable this if worker Node groups has access to internet to download the docker images
# Or Make it false and set the private contianer image repo url in source/main.tf; currently this defaults to ECR
public_docker_repo = true

#---------------------------------------------------------#
# ENABLE METRICS SERVER
#---------------------------------------------------------#
metrics_server_enable            = true
metric_server_image_tag          = "v0.4.2"
metric_server_helm_chart_version = "2.12.1"
#---------------------------------------------------------#
# ENABLE CLUSTER AUTOSCALER
#---------------------------------------------------------#
cluster_autoscaler_enable       = true
cluster_autoscaler_image_tag    = "v1.20.0"
cluster_autoscaler_helm_version = "9.9.2"

#---------------------------------------------------------//
# ENABLE AWS LB INGRESS CONTROLLER
#---------------------------------------------------------//
lb_ingress_controller_enable = true
aws_lb_image_tag             = "v2.2.1"
aws_lb_helm_chart_version    = "1.2.3"

#---------------------------------------------------------//
# ENABLE PROMETHEUS
#---------------------------------------------------------//
# Creates the AMP workspace and all the relevent IAM Roles
aws_managed_prometheus_enable = true

# Deploys Pometheus server with remote write to AWS AMP Workspace
prometheus_enable             = true
prometheus_helm_chart_version = "14.4.0"
prometheus_image_tag          = "v2.26.0"
alert_manager_image_tag       = "v0.21.0"
configmap_reload_image_tag    = "v0.5.0"
node_exporter_image_tag       = "v1.1.2"
pushgateway_image_tag         = "v1.3.1"

#---------------------------------------------------------#
# ENABLE AWS_FLUENT-BIT
#---------------------------------------------------------#
aws_for_fluent_bit_enable             = true
ekslog_retention_in_days              = 7
aws_for_fluent_bit_image_tag          = "2.17.0"
aws_for_fluent_bit_helm_chart_version = "0.1.11"

#---------------------------------------------------------#
# ENABLE TRAEFIK INGRESS CONTROLLER
#---------------------------------------------------------#
traefik_ingress_controller_enable = false
traefik_helm_chart_version        = "10.0.0"
traefik_image_tag                 = "v2.4.9"

#---------------------------------------------------------//
# ENABLE AGONES GAMING CONTROLLER
#   A library for hosting, running and scaling dedicated game servers on Kubernetes
#   This chart installs the Agones application and defines deployment on a  cluster
#   NOTE: Edit Rules to add a new Custom UDP Rule with a 7000-8000 port range and an appropriate Source CIDR range (0.0.0.0/0 allows all traffic) (sec group e.g., gaming-preprod-test-eks-eks_worker_sg)
#         By default Agones prefers to be scheduled on nodes labeled with agones.dev/agones-system=true and tolerates the node taint agones.dev/agones-system=true:NoExecute.
#         If no dedicated nodes are available, Agones will run on regular nodes.
#---------------------------------------------------------//
//agones_enable = true
//expose_udp    = true

#---------------------------------------------------------#
# ENABLE OPENTELEMETRY COLLECTOR FOR NODE GROUPS
#---------------------------------------------------------#
opentelemetry_enable                                  = true
opentelemetry_image                                   = "otel/opentelemetry-collector"
opentelemetry_image_tag                               = "0.31.0"
opentelemetry_command_name                            = "otelcol"
opentelemetry_helm_chart                              = "open-telemetry/opentelemetry-collector"
opentelemetry_helm_chart_version                      = "0.5.9"
opentelemetry_enable_standalone_collector             = true
opentelemetry_enable_agent_collector                  = true
opentelemetry_enable_autoscaling_standalone_collector = true
opentelemetry_enable_container_logs                   = true
opentelemetry_min_standalone_collectors               = 1
opentelemetry_max_standalone_collectors               = 10
