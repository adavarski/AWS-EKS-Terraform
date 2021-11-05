# AWS : Provisioning production-ready Amazon EKS clusters using Terraform

# Table of Contents:
-----------------------------------------------------------
# PART A: Architecture Overview
+ Introduction 
+ Solution outcomes 
+ Development environment requirements and code repository 
   + Development environment requirements 
   + Code repository for the solution 
+ High-level architecture 
   + Typical Amazon EKS architecture 
   + Planned high-level architecture 
+ Helm add-ons and Kubernetes Cluster Autoscaler 
   + Kubernetes Cluster Autoscaler 
+ Logging and monitoring Amazon EKS clusters 
+ Resources 

# PART B: Provisioning production-ready Amazon EKS clusters using Terraform
+ Main Purpose
+ Overview
+ EKS Cluster Deployment Options
   + EKS Cluster Networking Resources
   + EKS Cluster resources
   + Kubernetes Addons using Helm Charts
     + Ingress Controller Modules
     + Autoscaling Modules
     + Logging and Monitoring
     + Bottlerocket OS
+ How to Deploy
   + Prerequisites
   + Deployment Steps
   + Deploying example templates
   + Example: preprod dev environment
+ EKS Addons update
+ Important note
+ Notes

# PART C: Additional info
+ Maintainer
+ Security

-----------------------------------------------------------
   
# PART A: Architecture Overview

## Introduction
Kubernetes is an open-source system for automating and managing containerized applications at scale.
[Amazon Elastic Kubernetes Service (Amazon EKS)](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) is a managed service that runs container application
workloads and helps standardize operations across your environments (for example, production or
development environments). You can manage modern infrastructures by using infrastructure as code
(IaC) practices with tools such as AWS CloudFormation, AWS Cloud Development Kit (CDK) , or [Terraform
by Hashicorp](https://www.terraform.io/). This guide is intended for solution architects and technical leaders who are responsible
for designing production-ready Amazon EKS clusters to run modernized workloads. The solution uses
Terraform to build an IaC framework that provisions a multi-tenant Amazon EKS cluster. The guide
describes the outcomes, design, architecture, and implementation of Amazon EKS clusters for running
modernized application workloads.
By using this guide's solution, you can quickly create the infrastructure to migrate live-traffic serving
self-hosted Kubernetes clusters to Amazon EKS on the AWS Cloud. The guide also provides a framework
to help you design and create Amazon EKS clusters, each with a unique Terraform configuration and
state file, in different environments across multiple AWS accounts and AWS Regions. When you want to
modernize your applications with microservices and Kubernetes, you can use this guide and its reference
code in the GitHub aws-eks-production repository to build the Amazon EKS infrastructure
on the AWS Cloud. This provisions Amazon EKS clusters, managed node groups with [On-Demand](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) and
[Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) Amazon Elastic Compute Cloud (Amazon EC2) [instance types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html), AWS Fargate profiles, and plugins or
add-ons for creating production-ready Amazon EKS clusters. The [Terraform Helm provider](https://learn.hashicorp.com/tutorials/terraform/helm-provider?in=terraform/use-case) also deploys
common Kubernetes add-ons by using [Helm charts](https://helm.sh/docs/topics/charts/).

The guide has the following five sections:
 - Development environment requirements and code repository – Provides the software, tools,
and GitHub repository to implement this guide's solution.
 - High-level architecture – Explains the high-level architectural design of the guide's solution.
 - Helm add-ons and Kubernetes Cluster Autoscaler – Describes how to implement the Helm
modules by using Terraform Helm provider and how the Kubernetes Cluster Autoscaler helps scale
Amazon EKS clusters.
 - Logging and monitoring Amazon EKS clusters – Discusses the centralized logging and
monitoring solutions that can be implemented for Amazon EKS clusters.
 - Provisioning AWS EKS with terraform (examples)

After provisioning the Amazon EKS clusters, you can deploy the examples from Examples directory in
the GitHub aws-eks-production repository. However, this guide doesn't provide a complete
overview of all implementations and we recommend that you carefully evaluate all third-party or open-source tools according to your organization's policies and requirements.

## Solution outcomes 

You should expect the following eight outcomes from deploying this guide’s solution in your AWS
accounts:
- Enable your cross-functional teams to use the same Amazon EKS cluster by provisioning Amazon EKS
clusters that support multi-tenancy based on applications and namespaces.
- Provision Amazon EKS clusters in new or existing virtual private clouds (VPCs), which means that you
can use existing VPCs if required.
- Define your scaling metrics as a Kubernetes manifest by using Kubernetes [Horizontal Pod Autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html)
and configurable options for expanding resource quotas and pod security policies.
- Ensure role-based access control (RBAC) for your developers and administrators by using AWS Identity
and Access Management (IAM) roles.
- Deploy a private Amazon EKS cluster to secure your application and meet your compliance
requirements.
- Monitor and log applications and system pods by using Amazon CloudWatch to collect and track
metrics.
- Flexibly provision your Amazon EKS clusters with different node group types by running a combination
of self-managed nodes, Amazon EKS managed node groups, and Fargate.
- Deploy a [Bottlerocket](https://aws.amazon.com/bottlerocket/) Amazon Machine Image (AMI) in self-managed node groups to run container
workloads in a purpose-built operating system (OS) on the AWS Cloud.

## Development environment requirements and code repository

The following sections describe the software and tools required to set up your development
environment, in addition to the tools required to validate and monitor your Amazon Elastic Kubernetes
Service (Amazon EKS) clusters. An overview is also provided of the GitHub aws-eks-production repository that contains the code for this guide's solution.

### Development environment requirements
The following table shows the tools and versions to set up the development environment for building and deploying the guide's solution.
```
==================================================================================
Tool Version Purpose Ref()
==================================================================================
- Git 2.31.1 Version control (https://git-scm.com/downloads)
- Terraform 0.14.0 IaC (https://www.terraform.io/downloads.html)
- Helm 3 3.0.x Kubernetes packaging (https://helm.sh/docs/intro/install/)
- kubectl 1.18 Kubernetes command line interface (https://kubernetes.io/docs/tasks/tools/)
- Kubernetes Lens V4.2.2 User interface (UI) for cluster monitoring (https://k8slens.dev/)
```

### Code repository for the solution
The code framework in the GitHub aws-eks-production repository helps you to create
Amazon EKS clusters, each with unique Terraform configuration and state files, in different environments
across multiple AWS accounts and AWS Regions. The following list provides the outline of the
repository's contents:
- The top-level live directory contains the configuration for each Amazon EKS cluster. Each folder
under live/<region>/application represents an Amazon EKS cluster environment (for example,
development or testing). This directory contains the backend.conf and base.tfvars files
that create a unique Terraform state for each Amazon EKS cluster environment. You can update
backend.conf with the Terraform backend configuration and base.tfvars with the Amazon EKS
cluster common configuration variables.
-  The source directory contains the main.tf main driver file.
-  The modules directory contains the AWS resource modules.
-  The helm directory contains the Helm chart modules.
-  The examples directory contains sample template files with a base.tfvars file that you can use to
deploy Amazon EKS clusters with multiple add-on options.
-  The How to deploy section of the ReadMe file provides the step-by-step process and commands to
provision the Amazon EKS clusters.

## High-level architecture
The following sections explain the high-level architecture and components required for building the
Amazon Elastic Kubernetes Service (Amazon EKS) clusters and Helm add-ons.

### Typical Amazon EKS architecture
Typically, an Amazon EKS cluster consists of two main components, the control plane and the data
plane, that run in their own individual virtual private clouds (VPCs). In Amazon EKS, the control plane
is provided and maintained by AWS in a separate VPC. The nodes that you manage in your VPCs are
responsible for running the container images or workloads. AWS also provides the required networking
framework to integrate these components and create a Kubernetes cluster.
An Amazon EKS cluster can schedule pods on any combination of self-managed nodes, Amazon EKS
managed node groups, and AWS Fargate. Amazon EKS nodes run in your account and connect to the
cluster's control plane through the cluster’s API server endpoint. The following diagram shows the key
components of an Amazon EKS cluster and the relationship between these components and a VPC.

<img src="eks_cluster_images/Typical_Amazon_EKS_architecture.png?raw=true" width="900">
 
For more information about Amazon EKS cluster networking, see [Amazon EKS networking](https://docs.aws.amazon.com/eks/latest/userguide/eks-networking.html) in the Amazon
EKS documentation.

### Planned high-level architecture
This section describes the high-level architecture for the guide’s solution, in addition to the AWS services
and Helm modules that are used. The following diagram shows the high-level architecture for this
solution.

 <img src="eks_cluster_images/AWS_Provisioning_production-ready_Amazon_EKS_clusters_using_Terraform_Planned_high-level_architecture.png?raw=true" width="900">

  
The diagram shows the following components from this guide’s solution:
- Amazon EKS clusters in different environments in AWS accounts across multiple AWS Regions, with a
unique Terraform configuration and state file for each Amazon EKS cluster.
- One VPC with private subnets in each Availability Zone for nodes.
- VPC endpoints to access AWS services across AWS accounts.
- Managed node groups with [On-Demand](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) Instances.
- Managed node groups with [Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) Instances.
- Fargate profiles run serverless workloads.
- Amazon Elastic Container Registry (Amazon ECR) stores the Docker images for application
microservices and Helm add-ons for application deployments.
- On-Demand instances in an Amazon EC2 Auto Scaling group that are used as underlying computing
infrastructure for the Amazon EKS cluster.
- Nodes deployed over multiple Availability Zones and using Amazon EC2 Auto Scaling groups.
- An Amazon Route 53 Domain Name System (DNS) zone for service discovery and a Network Load
Balancer configured for HTTPS encrypted traffic.
- AWS Certificate Manager (ACM) to provision Secure Sockets Layer/Transport Layer Security (SSL/TLS)
certificates for secure communication.
- [Kubernetes Metrics Server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html) to collect metrics from running pods, such as CPU and memory utilization.
- Kubernetes Cluster Autoscaler to scale in and out of nodes.
- An Application Load Balancer ingress controller to load balance the application traffic.
- [Amazon CloudWatch with Fluent Bit](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html) for logging application logs and cluster logs.
- Amazon Elasticsearch Service (Amazon ES) and Amazon Simple Storage Service (Amazon S3) for
centralized logging.

## Helm add-ons and Kubernetes Cluster Autoscaler

Helm is a package manager for Kubernetes that helps you install and manage applications in your
Kubernetes cluster. Helm packages multiple Kubernetes resources into a single logical deployment unit
called a [chart](https://helm.sh/). Helm charts are available in the [Helm directory](https://github.com/adavarski/aws-eks-production/tree/main/helm) in the GitHub aws-eks-production repository. This guide’s solution helps you to launch an Amazon Elastic Kubernetes Service
(Amazon EKS) cluster with the following Helm charts.


(Amazon EKS) cluster with the following Helm charts.
```
Chart name Namespace Chart version Application version Docker version (Ref)
==============================================================================
cluster-autoscaler kube-system 9.9.2 1.19.1 v1.19.1 (https://github.com/kubernetes/autoscaler)
aws-for-fluent-bit logging 0.1.7 2.6.1 2.12.0 (https://github.com/aws/aws-for-fluent-bit)
metric-server kube-system 2.11.4 0.3.6 v0.3.6 (https://github.com/kubernetes-sigs/metrics-server)
newrelic-infrastructure kube-system 1.3.1 1.26.2 1.26.2 (https://github.com/newrelic/helm-charts)
AWS Load Balancer Controller aws-load-balancer-controller 1.1.6 v2.1.3 v2.1.3 (https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller)
==============================================================================
```
Important:
This guide's tool or component versions can change and might switch to other tools with similar
capabilities.

### Kubernetes Cluster Autoscaler
The [Kubernetes Cluster Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html) is an add-on that adjusts the size of a Kubernetes cluster to meet your
workload resource requirements. Kubernetes Cluster Autoscaler increases the size of the cluster when
pods failed to schedule on current nodes due to insufficient resources and it also attempts to remove
underutilized nodes.
Kubernetes Cluster Autoscaler automatically scales Amazon Elastic Compute Cloud (Amazon EC2)
instances according to the resource requirements of the pods. You can use Kubernetes Cluster Autoscaler
to control scaling activities by changing the required capacity of the Amazon EC2 Auto Scaling group
and directly terminating instances. Each node group maps to a single Amazon EC2 Auto Scaling group;
however, Kubernetes Cluster Autoscaler requires that all EC2 instances in a node group share the same
vCPU number and RAM amount.

## Logging and monitoring Amazon
EKS clusters
Logging and monitoring for Amazon Elastic Kubernetes Service (Amazon EKS) has two categories:
the control plane logs and the application logs. Amazon EKS control plane logging provides audit and
diagnostic logs from the control plane to Amazon CloudWatch Logs groups in your AWS account. To
collect application logs you must install a log aggregator, such as [Fluent Bit](https://fluentbit.io/), [Fluentd](https://www.fluentd.org/), or [CloudWatch
Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html), in your Amazon EKS cluster.
[Fluent Bit](https://fluentbit.io/) is an open-source log processor and forwarder that is written in C++, which means that you
can collect data from different sources, enrich them with filters, and send them to multiple destinations.
By using this guide's solution you can enable aws-for-fluent-bit or fargate-fluentbit for
logging. [Fluentd](https://www.fluentd.org/) is an open-source data collector for unified logging layer and written in Ruby. Fluentd
acts as a unified logging layer that can aggregate data from multiple sources, unify data with different
formats into JSON-formatted objects, and route them to different output destinations.
Choosing a log collector is important for CPU and memory utilization when you monitor thousands of
servers. If you have multiple Amazon EKS clusters, you can use Fluent Bit as a lightweight shipper to
collect data from different nodes in the cluster and forward it to Fluentd for aggregation, processing and
routing to a supported output destination.
It's very important to monitor and maintain the performance and health of your scalable Kubernetes
environments. You can monitor the Amazon EKS clusters in real time by streaming metrics to [New Relic](https://newrelic.com/)
or [Datadog](https://www.datadoghq.com/) for better observability. New Relic and Datadog provide holistic views of the performance
and health of Kubernetes clusters, down to the node, container, and application-level visibility required
to identify and troubleshoot performance issues. We recommend using Fluent Bit as a log collector and
using New Relic or Datadog for better observability. The following list provides three options for logging
and monitoring your Amazon EKS clusters:
- Option 1 – Use Fluent Bit as the log collector and forwarder to send application and cluster logs to
CloudWatch. You can then stream the logs to Amazon Elasticsearch Service (Amazon ES) using an
Elasticsearch subscription filter in CloudWatch. This option is shown in this section's architecture
diagram.
- Option 2 – Use a Datadog agent as the log and metric collector and forwarder to stream logs and
metrics to the Datadog UI.
- Option 3 – Use a New Relic agent as the log and metric collector and forwarder to stream logs and
metrics to the New Relic UI.
The following diagram shows a logging architecture that automatically streams logs from multiple
accounts to a centralized logs server.


The following diagram shows a logging architecture that automatically streams logs from multiple
accounts to a centralized logs server.

<img src="eks_cluster_images/AWS_Provisioning_production-ready_Amazon_EKS_clusters_using_Terraforme.png?raw=true" width="900">
 
  
The diagram shows the following workflow when application logs from Amazon EKS clusters are
streamed to Amazon ES:
1. The Fluent Bit service in the Amazon EKS cluster pushes the logs to CloudWatch.
2. The AWS Lambda function streams the logs to Amazon ES using an Elasticsearch subscription filter.
3. You can then use Kibana to visualize the logs in the configured indexes.
4. You can also stream logs by using Amazon Kinesis Data Firehose and store them in an S3 bucket for
analysis and querying with [Amazon Athena](https://docs.aws.amazon.com/athena/latest/ug/what-is.html).

## Resources
- [Logging for Amazon Elastic Kubernetes Service (Amazon EKS)](https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-logging-monitoring-cloudwatch/kubernetes-eks-logging.html)
- [Centralized container logging with Fluent Bit](https://aws.amazon.com/blogs/opensource/centralized-container-logging-fluent-bit/)
- [Terminate HTTPS traffic on Amazon EKS workloads with AWS Certificate Manager (ACM)](https://aws.amazon.com/premiumsupport/knowledge-center/terminate-https-traffic-eks-acm/)
- [Set up end-to-end TLS encryption on Amazon EKS with the AWS Load Balancer Controller](https://aws.amazon.com/blogs/containers/setting-up-end-to-end-tls-encryption-on-amazon-eks-with-the-new-aws-load-balancer-controller/)
- [Amazon EKS best practices guide for security](https://aws.github.io/aws-eks-best-practices/security/docs/)
- [Amazon EKS platform versions](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html)
- [Designing and implementing logging and monitoring with Amazon CloudWatch](https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-logging-monitoring-cloudwatch/welcome.html)
- Amazon EKS AMI Build Specification && EKS Distro Repository: https://github.com/awslabs/amazon-eks-ami && https://github.com/aws/eks-distro Note:  Amazon EKS provides specialized Amazon Machine Images (AMI) called Amazon EKS optimized AMIs. The AMIs are configured to work with Amazon EKS and include 1.Docker/Containerd( EKS 1.21), 2.kubelet , and 3.the AWS IAM Authenticator. The AMIs also contain a specialized 4.bootstrap script that allows it to discover and connect
to your cluster's control plane automatically. 
   
   
   
# PART B: Provisioning production-ready Amazon EKS clusters using Terraform
## Main Purpose
This project provides a framework for deploying best-practice multi-tenant [EKS Clusters](https://aws.amazon.com/eks), provisioned via [Hashicorp Terraform](https://www.terraform.io/) and [Helm charts](https://helm.sh/) on [AWS](https://aws.amazon.com/).

## Overview
The AWS EKS Production with Terraform module helps you to provision [EKS Clusters](https://aws.amazon.com/eks), [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) with [on-demand](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) and [spot instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html), [Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html), and all the necessary plugins/add-ons for a production-ready EKS cluster. The [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy common Kubernetes add-ons with publicly available [Helm Charts](https://artifacthub.io/). This project leverages the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to create EKS Clusters

This framework helps you to design and create EKS clusters for different environments in various AWS accounts across multiple regions with a **unique Terraform configuration and state file** per EKS cluster.

* The top-level `live` folder contains the configuration for each cluster. Each folder under `live/<region>/application` represents an EKS cluster environment(e.g., dev, test, load etc.).
This folder contains `backend.conf` and `base.tfvars`, used to create a unique Terraform state for each cluster environment.
Terraform backend configuration can be updated in `backend.conf` and cluster common configuration variables in `base.tfvars`

* `source` folder contains main driver file `main.tf`
* `modules` folder contains all the AWS resource modules
* `helm` folder contains all the Helm chart modules
* `examples` folder contains sample template files with `base.tfvars` which can be used to deploy clusters with multiple add-on options

## EKS Cluster Deployment Options
This module provisions the following EKS resources

### EKS Cluster Networking Resources

1. [VPC and Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
    - [Public Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
    - [Private Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
2. [VPC endpoints for fully private EKS Clusters](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
3. [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
4. [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)

### EKS Cluster resources

1. [EKS Cluster with multiple networking options](https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/)
   1. [Fully Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
   2. [Public + Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
   3. [Public Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html))
2. [EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) -
   - [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
   - [Kube-Proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
   - [VPC-CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
3. [Managed Node Groups with On-Demand](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with On-Demand Instances
4. [Managed Node Groups with Spot](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with Spot Instances
5. [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) - AWS Fargate Profiles
6. [Launch Templates with SSM agent](https://aws.amazon.com/blogs/containers/introducing-launch-template-and-custom-ami-support-in-amazon-eks-managed-node-groups/) - Deployed through launch templates to Managed Node Groups
7. [Bottlerocket OS](https://github.com/bottlerocket-os/bottlerocket) - Managed Node Groups with Bottlerocket OS and Launch Templates
8. [RBAC](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) for Developers and Administrators with IAM roles
9. [Amazon Managed Service for Prometheus (AMP)](https://aws.amazon.com/prometheus/) - AMP makes it easy to monitor containerized applications at scale
10. [Self-managed Node Group with Windows support](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html) - Ability to create a self-managed node group for Linux or Windows workloads. See [Windows](./examples/windows-support) and [Linux](./examples/self-managed-linux-nodegroup) examples.

### Kubernetes Addons using [Helm Charts](https://helm.sh/docs/topics/charts/)

1. [Metrics Server](https://github.com/Kubernetes-sigs/metrics-server)
2. [Cluster Autoscaler](https://github.com/Kubernetes/autoscaler)
3. [AWS LB Ingress Controller](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
4. [Traefik Ingress Controller](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)
5. [FluentBit to CloudWatch for Managed Node groups](https://github.com/aws/aws-for-fluent-bit)
6. [FluentBit to CloudWatch for Fargate Containers](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/)
7. [Agones](https://agones.dev/site/) - Host, Run and Scale dedicated game servers on Kubernetes
8. [Prometheus](https://github.com/prometheus-community/helm-charts)
9. [Kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics)
10. [Alert-manager](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)
11. [Prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
12. [Prometheus-pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway)
13. [OpenTelemetry](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)

## Helm Charts Modules
Helm Chart Module within this framework allows you to deploy Kubernetes  apps using Terraform helm chart provider with **enabled** conditional parameter in `base.tfvars`.

You can find the README for each Helm module with instructions on how to download the images from Docker Hub or third-party repos and upload it to your private ECR repo.

For example, [ALB Ingress Controller](helm/lb_ingress_controller/README.md) for AWS LB Ingress Controller module.

### Ingress Controller Modules
Ingress is an API object that defines the traffic routing rules (e.g., load balancing, SSL termination, path-based routing, protocol), whereas the Ingress Controller is the component responsible for fulfilling those requests.

* [ALB Ingress Controller](helm/lb_ingress_controller/README.md) can be deployed by specifying the following line in `base.tfvars` file.
**AWS ALB Ingress controller** triggers the creation of an ALB and the necessary supporting AWS resources whenever a Kubernetes  user declares an Ingress resource in the cluster.
[ALB Docs](https://Kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

    `alb_ingress_controller_enable = true`

* [Traefik Ingress Controller](helm/traefik_ingress/README.md) can be deployed by specifying the following line in `base.tfvars` file.
**Traefik is an open source Kubernetes  Ingress Controller**. The Traefik Kubernetes  Ingress provider is a Kubernetes  Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification. For more details about [Traefik can be found here](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)

    `traefik_ingress_controller_enable = true`

### Autoscaling Modules
**Cluster Autoscaler** and **Metric Server** Helm Modules gets deployed by default with the EKS Cluster.

* [Cluster Autoscaler](helm/cluster_autoscaler/README.md) can be deployed by specifying the following line in `base.tfvars` file.
The Kubernetes  Cluster Autoscaler automatically adjusts the number of nodes in your cluster when pods fail or are rescheduled onto other nodes. It's not deployed by default in EKS clusters.
That is, the AWS Cloud Provider implementation within the Kubernetes  Cluster Autoscaler controls the **DesiredReplicas** field of Amazon EC2 Auto Scaling groups.
The Cluster Autoscaler is typically installed as a **Deployment** in your cluster. It uses leader election to ensure high availability, but scaling is one done by a single replica at a time.

    `cluster_autoscaler_enable = true`

* [Metrics Server](helm/metrics_server/README.md) can be deployed by specifying the following line in `base.tfvars` file.
The Kubernetes  Metrics Server, used to gather metrics such as cluster CPU and memory usage over time, is not deployed by default in EKS clusters.

    `metrics_server_enable = true`

### Logging and Monitoring
**FluentBit** is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

* [aws-for-fluent-bit](helm/aws-for-fluent-bit/README.md) can be deployed by specifying the following line in `base.tfvars` file.
AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The AWS for Fluent Bit image is available on the Amazon ECR Public Gallery.
For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

    `aws-for-fluent-bit_enable = true`

* [fargate-fluentbit](helm/fargate_fluentbit) can be deployed by specifying the following line in `base.tfvars` file.
This module ships the Fargate Container logs to CloudWatch

    `fargate_fluent_bit_enable = true`

### Bottlerocket OS

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is an open source operating system specifically designed for running containers. Bottlerocket build system is based on Rust. It's a container host OS and doesn't have additional software's or package managers other than what is needed for running containers hence its very light weight and secure. Container optimized operating systems are ideal when you need to run applications in Kubernetes  with minimal setup and do not want to worry about security or updates, or want OS support from  cloud provider. Container operating systems does updates transactionally.

Bottlerocket has two containers runtimes running. Control container **on** by default used for AWS Systems manager and remote API access. Admin container **off** by default for deep debugging and exploration.

Bottlerocket [Launch templates userdata](modules/launch-templates/templates/bottlerocket-userdata.sh.tpl) uses the TOML format with Key-value pairs. Remote API access API via SSM agent. You can launch trouble shooting container via user data `[settings.host-containers.admin] enabled = true`.

#### Features
* [Secure](https://github.com/bottlerocket-os/bottlerocket/blob/develop/SECURITY_FEATURES.md) - Opinionated, specialized and highly secured
* **Flexible** - Multi cloud and multi orchestrator
* **Transactional** -  Image based upgraded and rollbacks
* **Isolated** - Separate container Runtimes

#### Updates
Bottlerocket can be updated automatically via Kubernetes  Operator

```shell script
    kubectl apply -f Bottlerocket_k8s.csv.yaml
    kubectl get ClusterServiceVersion Bottlerocket_k8s | jq.'status'
```

## How to Deploy

### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [wget](https://www.gnu.org/software/wget/)
5. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
6. [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) - currently needed to enable Windows support

### Deployment Steps
The following steps walks you through the deployment of example [DEV cluster](live/preprod/eu-west-1/application/dev/base.tfvars) configuration. This config deploys a private EKS cluster with public and private subnets.

Two managed worker nodes with On-demand and Spot instances along with one fargate profile for default namespace placed in private subnets. ALB placed in Public subnets created by LB Ingress controller.

It also deploys few kubernetes apps i.e., LB Ingress Controller, Metrics Server, Cluster Autoscaler, aws-for-fluent-bit CloudWatch logging for Managed node groups, FluentBit CloudWatch logging for Fargate etc.

#### Provision VPC (optional) and EKS cluster with selected Helm modules

##### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/adavarski/aws-eks-production.git
```

##### Step2: Update base.tfvars file

Update `~/aws-eks-production/live/preprod/eu-west-1/application/dev/base.tfvars` file with the instructions specified in the file (OR use the default values). You can choose to use an existing VPC ID and Subnet IDs or create a new VPC and subnets by providing CIDR ranges in `base.tfvars` file

#####  Step3: Update Terraform backend config file

Update `~/aws-eks-production/live/preprod/eu-west-1/application/dev/backend.conf` with your local directory path. [state.tf](source/state.tf) file contains backend config.

Local terraform state backend config variables

```hcl-terraform
    path = "local_tf_state/ekscluster/preprod/application/dev/terraform-main.tfstate"
```

It's highly recommended to use remote state in S3 instead of using local backend. The following variables needs filling for S3 backend.

```hcl-terraform
    bucket = "<s3 bucket name>"
    region = "<aws region>"
    key    = "ekscluster/preprod/application/dev/terraform-main.tfstate"
```

##### Step4: Assume IAM role before creating a EKS cluster.
This role will become the Kubernetes  Admin by default.

```shell script
aws-mfa --assume-role  arn:aws:iam::<ACCOUNTID>:role/<IAMROLE>
```
Note: not needed to execute above command if using your AWS account

##### Step5: Run Terraform INIT
to initialize a working directory with configuration files

```shell script
terraform -chdir=source init -backend-config ../live/preprod/eu-west-1/application/dev/backend.conf
```


##### Step6: Run Terraform PLAN
to verify the resources created by this execution

```shell script
terraform -chdir=source plan -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars
```

##### Step7: Finally, Terraform APPLY
to create resources

```shell script
terraform -chdir=source apply -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars
```

**Alternatively you can use Makefile to deploy by skipping Step5, Step6 and Step7**

#### Deploy EKS Cluster using [Makefile](Makefile)

##### Executing Terraform PLAN
    $ make tf-plan-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    $ make tf-plan-eks env=preprod region=eu-west-1 account=application subenv=dev

##### Executing Terraform APPLY
    $ make tf-apply-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    $ make tf-apply-eks env=preprod region=eu-west-1 account=application subenv=dev

##### Executing Terraform DESTROY
    $ make tf-destroy-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    make tf-destroy-eks env=preprod region=eu-west-1 account=application subenv=dev

#### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

##### Step8: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region eu-west-1 update-kubeconfig --name <cluster-name>

##### Step9: List all the worker nodes by running the command below

    $ kubectl get nodes

##### Step10: List all the pods running in kube-system namespace

    $ kubectl get pods -n kube-system

### Deploying example templates
The `examples` folder contains multiple cluster templates with pre-populated `.tfvars` which can be used as a quick start. Reuse the templates from `examples` and follow the above Deployment steps as mentioned above.
   
Note: Create cluster using current k8s VPC and private networks (to access APP/DB VMs in current private subnets)
```
Example file: live/preprod/eu-west-1/application/dev/base.tfvars
#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
//create_vpc = false
//vpc_id = "xxxxxx"
//private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']
create_vpc = false
vpc_id = "vpc-08fe8a789e9c7318c"
private_subnet_ids = ["subnet-021e8e40ae0f41e27","subnet-
03f19c6cb25621f19","subnet-0c15a71153934f3a8"]   
```
   
### Example: preprod dev environment
```
$ terraform -chdir=source apply -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: eu-central-1
...
...   
module.helm.module.metrics_server[0].helm_release.metrics_server: Creation complete after 34s [id=metrics-server]
module.helm.module.prometheus[0].helm_release.prometheus: Still creating... [40s elapsed]
module.helm.module.prometheus[0].helm_release.prometheus: Still creating... [50s elapsed]
module.helm.module.prometheus[0].helm_release.prometheus: Still creating... [1m0s elapsed]
module.helm.module.prometheus[0].helm_release.prometheus: Still creating... [1m10s elapsed]
module.helm.module.prometheus[0].helm_release.prometheus: Creation complete after 1m11s [id=prometheus]
 
$ aws sts get-caller-identity
{
    "UserId": "218645542363",
    "Account": "218645542363",
    "Arn": "arn:aws:iam::218645542363:root"
}
$ export KUBECONFIG=./config
$ aws eks --region eu-central-1 update-kubeconfig --name tarya-preprod-dev-eks   
$ cat config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeE1EZ3lOVEEwTWprMU4xb1hEVE14TURneU16QTBNamsxTjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT1U2CjZwYVBadkpISDFvZytrYWZaUmRycXBpM0o2RkV0TDFrYjdiV0xVNExCa05iaFg4WHMrUi9STHVOSGkrbGx2UW8KZjdMckliNEM0c0dNUGIwVUNJOWpwUnM1MjJLTllwM1g4VWNTdmsvbkJKUDl6NW43VCtLdHhmRkJIVXpLSG5jZQo4dDVSREhMVVJCazlaVjlXaEppTDlZc09aZEQxZ1hPamE0UXlybTEzdEpGek1xTVhlSktieEtaVkFtYXA2MEJpClp1S2ZRaEUwTHU4TlZoV0pUNEd4STdwUHJkbjJnUEh3a0djRlgrWHc4cm1zRFdTVmdJd0RWbEJTcmhYRHlZVEsKT3FpMVhvRzE3WmlrdWp3SEhleENOWlk4NDhKa2M1UnVFMmV5VUJmdnBXek1Qa0l2WWhpLy9aWGwwaDdPZEtPQgo0TWJJRVFIeHZ5c20rZThsQzlzQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZNQUV4UmlnS1MwVkRDWXVXaXh4cnJ4WlJRdkFNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBdmZrWUhiMHZzdTBUS0NKcllLUnplTFpTNytYbUM5dnNsbVBvQWNOQTU3RmZOYkEzeApkbEY2anJaN2kvS2lsSGFYSGs2V3o4ZDgycFJnSjByV3Z1NU5RcFF3bHFEcDV1bkJSd3VDdzlvNkhyNXRadmhVClh5VEhTTGdvaVJjOW5sdG43SXROZEJYT1JZZGpIa0ljYU5EcVBQa3A1SHBFNmx1NjVPVjZMVU9rRDBYbCs1TU4KdDBBazFZMTZIMWJaTWRaUm8rMllqc1ZUOEFha1g1L1B1UG1kRWpRRjJveW0vclZiQmo1U0VoajBGMnBxVXRmdQplZ0x1b1FHdG54OGZlc242YUVudzVBQzNVdDJlUDdpY2d2cXJOeXBuTHJ3bXRoWm8vSTdtN3Z5eUp3eHRMdG81CmY4cjdhWi9FUWhVSXJiRW5FZG9rL3pEMVo0UHlyV3lDQVNSMgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://F456B8B6FC84724728C3D60B5F6067A3.gr7.eu-central-1.eks.amazonaws.com
  name: arn:aws:eks:eu-central-1:218645542363:cluster/tarya-preprod-dev-eks
contexts:
- context:
    cluster: arn:aws:eks:eu-central-1:218645542363:cluster/tarya-preprod-dev-eks
    user: arn:aws:eks:eu-central-1:218645542363:cluster/tarya-preprod-dev-eks
  name: arn:aws:eks:eu-central-1:218645542363:cluster/tarya-preprod-dev-eks
current-context: arn:aws:eks:eu-central-1:218645542363:cluster/tarya-preprod-dev-eks
kind: Config
preferences: {}
users:
- name: arn:aws:eks:eu-central-1:218645542363:cluster/tarya-preprod-dev-eks
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - eu-central-1
      - eks
      - get-token
      - --cluster-name
      - tarya-preprod-dev-eks
      command: aws
$ kubectl cluster-info
Kubernetes master is running at https://F456B8B6FC84724728C3D60B5F6067A3.gr7.eu-central-1.eks.amazonaws.com
CoreDNS is running at https://F456B8B6FC84724728C3D60B5F6067A3.gr7.eu-central-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
$ kubectl get nodes -o wide
NAME                                         STATUS   ROLES    AGE   VERSION              INTERNAL-IP   EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                CONTAINER-RUNTIME
ip-10-1-1-72.eu-central-1.compute.internal   Ready    <none>   16m   v1.20.4-eks-6b7464   10.1.1.72     <none>        Amazon Linux 2   5.4.129-63.229.amzn2.x86_64   docker://19.3.13
$ kubectl get all --all-namespaces
NAMESPACE     NAME                                                            READY   STATUS    RESTARTS   AGE
kube-system   pod/aws-load-balancer-controller-675687fcb7-m9bns               1/1     Running   0          15m
kube-system   pod/aws-node-tvc68                                              1/1     Running   0          16m
kube-system   pod/cluster-autoscaler-aws-cluster-autoscaler-74d897d8b-q79l2   1/1     Running   0          15m
kube-system   pod/cluster-autoscaler-aws-cluster-autoscaler-74d897d8b-rd6wf   1/1     Running   0          15m
kube-system   pod/coredns-85cc4f6d5-f44k2                                     1/1     Running   0          28m
kube-system   pod/coredns-85cc4f6d5-w476z                                     1/1     Running   0          28m
kube-system   pod/kube-proxy-m5d7c                                            1/1     Running   0          16m
kube-system   pod/metrics-server-5fdcc4b6fd-5qv25                             1/1     Running   0          15m
kube-system   pod/metrics-server-5fdcc4b6fd-ch7fk                             1/1     Running   0          15m
kube-system   pod/metrics-server-5fdcc4b6fd-m4zbc                             1/1     Running   0          15m
logging       pod/aws-for-fluent-bit-6gzgt                                    1/1     Running   0          15m
prometheus    pod/prometheus-alertmanager-c698644f9-jjqh4                     2/2     Running   0          15m
prometheus    pod/prometheus-kube-state-metrics-5dfdffb78b-jzh2w              1/1     Running   0          15m
prometheus    pod/prometheus-node-exporter-68mt9                              1/1     Running   0          15m
prometheus    pod/prometheus-pushgateway-fd9b7dfb5-rxh4w                      1/1     Running   0          15m
prometheus    pod/prometheus-server-7d8cb8b459-dnqgc                          2/2     Running   0          15m

NAMESPACE     NAME                                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes                                  ClusterIP   172.20.0.1       <none>        443/TCP         28m
kube-system   service/aws-load-balancer-webhook-service           ClusterIP   172.20.121.0     <none>        443/TCP         15m
kube-system   service/cluster-autoscaler-aws-cluster-autoscaler   ClusterIP   172.20.81.225    <none>        8085/TCP        15m
kube-system   service/kube-dns                                    ClusterIP   172.20.0.10      <none>        53/UDP,53/TCP   28m
kube-system   service/metrics-server                              ClusterIP   172.20.71.45     <none>        443/TCP         15m
prometheus    service/prometheus-alertmanager                     ClusterIP   172.20.132.240   <none>        80/TCP          15m
prometheus    service/prometheus-kube-state-metrics               ClusterIP   172.20.174.109   <none>        8080/TCP        15m
prometheus    service/prometheus-node-exporter                    ClusterIP   None             <none>        9100/TCP        15m
prometheus    service/prometheus-pushgateway                      ClusterIP   172.20.117.189   <none>        9091/TCP        15m
prometheus    service/prometheus-server                           ClusterIP   172.20.91.72     <none>        80/TCP          15m

NAMESPACE     NAME                                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/aws-node                   1         1         1       1            1           <none>                   28m
kube-system   daemonset.apps/kube-proxy                 1         1         1       1            1           <none>                   28m
logging       daemonset.apps/aws-for-fluent-bit         1         1         1       1            1           kubernetes.io/os=linux   15m
prometheus    daemonset.apps/prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   15m

NAMESPACE     NAME                                                        READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/aws-load-balancer-controller                1/1     1            1           15m
kube-system   deployment.apps/cluster-autoscaler-aws-cluster-autoscaler   2/2     2            2           15m
kube-system   deployment.apps/coredns                                     2/2     2            2           28m
kube-system   deployment.apps/metrics-server                              3/3     3            3           15m
prometheus    deployment.apps/prometheus-alertmanager                     1/1     1            1           15m
prometheus    deployment.apps/prometheus-kube-state-metrics               1/1     1            1           15m
prometheus    deployment.apps/prometheus-pushgateway                      1/1     1            1           15m
prometheus    deployment.apps/prometheus-server                           1/1     1            1           15m

NAMESPACE     NAME                                                                  DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/aws-load-balancer-controller-675687fcb7               1         1         1       15m
kube-system   replicaset.apps/cluster-autoscaler-aws-cluster-autoscaler-74d897d8b   2         2         2       15m
kube-system   replicaset.apps/coredns-85cc4f6d5                                     2         2         2       28m
kube-system   replicaset.apps/metrics-server-5fdcc4b6fd                             3         3         3       15m
prometheus    replicaset.apps/prometheus-alertmanager-c698644f9                     1         1         1       15m
prometheus    replicaset.apps/prometheus-kube-state-metrics-5dfdffb78b              1         1         1       15m
prometheus    replicaset.apps/prometheus-pushgateway-fd9b7dfb5                      1         1         1       15m
prometheus    replicaset.apps/prometheus-server-7d8cb8b459                          1         1         1       15m

### Exposing an External IP Address to Access an Application in a Cluster ---> Ref: https://kubernetes.io/docs/tutorials/stateless-application/expose-external-ip-address/
$ vi load-balancer-example.yaml
$ cat load-balancer-example.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: load-balancer-example
  name: hello-world
spec:
  replicas: 5
  selector:
    matchLabels:
      app.kubernetes.io/name: load-balancer-example
  template:
    metadata:
      labels:
        app.kubernetes.io/name: load-balancer-example
    spec:
      containers:
      - image: gcr.io/google-samples/node-hello:1.0
        name: hello-world
        ports:
        - containerPort: 8080
$ kubectl apply -f https://k8s.io/examples/service/load-balancer-example.yaml
deployment.apps/hello-world created
$ kubectl get deployments hello-world
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
hello-world   5/5     5            5           28s
$ kubectl describe deployments hello-world
Name:                   hello-world
Namespace:              default
CreationTimestamp:      Wed, 25 Aug 2021 08:03:59 +0300
Labels:                 app.kubernetes.io/name=load-balancer-example
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app.kubernetes.io/name=load-balancer-example
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app.kubernetes.io/name=load-balancer-example
  Containers:
   hello-world:
    Image:        gcr.io/google-samples/node-hello:1.0
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   hello-world-6df5659cb7 (5/5 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  32s   deployment-controller  Scaled up replica set hello-world-6df5659cb7 to 5
$ kubectl get replicasets
NAME                     DESIRED   CURRENT   READY   AGE
hello-world-6df5659cb7   5         5         5       54s
$ kubectl describe replicasets
Name:           hello-world-6df5659cb7
Namespace:      default
Selector:       app.kubernetes.io/name=load-balancer-example,pod-template-hash=6df5659cb7
Labels:         app.kubernetes.io/name=load-balancer-example
                pod-template-hash=6df5659cb7
Annotations:    deployment.kubernetes.io/desired-replicas: 5
                deployment.kubernetes.io/max-replicas: 7
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/hello-world
Replicas:       5 current / 5 desired
Pods Status:    5 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app.kubernetes.io/name=load-balancer-example
           pod-template-hash=6df5659cb7
  Containers:
   hello-world:
    Image:        gcr.io/google-samples/node-hello:1.0
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  62s   replicaset-controller  Created pod: hello-world-6df5659cb7-4ctkm
  Normal  SuccessfulCreate  62s   replicaset-controller  Created pod: hello-world-6df5659cb7-jmx5r
  Normal  SuccessfulCreate  62s   replicaset-controller  Created pod: hello-world-6df5659cb7-vb5bp
  Normal  SuccessfulCreate  62s   replicaset-controller  Created pod: hello-world-6df5659cb7-n4946
  Normal  SuccessfulCreate  62s   replicaset-controller  Created pod: hello-world-6df5659cb7-srdb6
$ kubectl expose deployment hello-world --type=LoadBalancer --name=my-service
service/my-service exposed
$ kubectl get services my-service
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP                                                                 PORT(S)          AGE
my-service   LoadBalancer   172.20.56.248   af67cf5c260e645968c79effeb289fcd-475261582.eu-central-1.elb.amazonaws.com   8080:31676/TCP   8s
$ kubectl describe services my-service
Name:                     my-service
Namespace:                default
Labels:                   app.kubernetes.io/name=load-balancer-example
Annotations:              <none>
Selector:                 app.kubernetes.io/name=load-balancer-example
Type:                     LoadBalancer
IP:                       172.20.56.248
LoadBalancer Ingress:     af67cf5c260e645968c79effeb289fcd-475261582.eu-central-1.elb.amazonaws.com
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  31676/TCP
Endpoints:                10.1.1.134:8080,10.1.1.22:8080,10.1.1.66:8080 + 2 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  23s   service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   21s   service-controller  Ensured load balancer
$ kubectl get pods --output=wide
NAME                           READY   STATUS    RESTARTS   AGE    IP           NODE                                         NOMINATED NODE   READINESS GATES
hello-world-6df5659cb7-4ctkm   1/1     Running   0          106s   10.1.3.120   ip-10-1-1-72.eu-central-1.compute.internal   <none>           <none>
hello-world-6df5659cb7-jmx5r   1/1     Running   0          106s   10.1.3.174   ip-10-1-1-72.eu-central-1.compute.internal   <none>           <none>
hello-world-6df5659cb7-n4946   1/1     Running   0          106s   10.1.1.66    ip-10-1-1-72.eu-central-1.compute.internal   <none>           <none>
hello-world-6df5659cb7-srdb6   1/1     Running   0          106s   10.1.1.22    ip-10-1-1-72.eu-central-1.compute.internal   <none>           <none>
hello-world-6df5659cb7-vb5bp   1/1     Running   0          106s   10.1.1.134   ip-10-1-1-72.eu-central-1.compute.internal   <none>           <none>
$ curl http://af67cf5c260e645968c79effeb289fcd-475261582.eu-central-1.elb.amazonaws.com:8080
Hello Kubernetes!


$ kubectl delete services my-service
service "my-service" deleted
$ kubectl describe services my-service
Error from server (NotFound): services "my-service" not found

### Clean AWS EKS cluster dev environment
$ terraform -chdir=source destroy -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: eu-central-1

aws_kms_key.eks: Refreshing state... [id=84dc6be0-7978-48c9-9615-698af83b8fc9]
...
...
   
module.vpc.aws_vpc.this[0]: Destruction complete after 0s
module.eks.aws_iam_role.cluster[0]: Destruction complete after 3s

Destroy complete! Resources: 122 destroyed.   
   
### TODO:
1.TF apply ---> opentelemetry_enable= true ---> false (because of error) && coredns is Degraded in the beggining, but after some minutes is OK (TF apply aggain is fixes it)

╷
│ Error: chart "open-telemetry/opentelemetry-collector" version "0.5.9" not found in https://open-telemetry.github.io/opentelemetry-helm-charts repository
│ 
│   with module.helm.module.opentelemetry_collector[0].helm_release.opentelemetry-collector,
│   on ../helm/opentelemetry_collector/main.tf line 29, in resource "helm_release" "opentelemetry-collector":
│   29: resource "helm_release" "opentelemetry-collector" {
│ 
╵
╷
│ Error: unexpected EKS Add-On (tarya-preprod-dev-eks:coredns) state returned during creation: unexpected state 'DEGRADED', wanted target 'ACTIVE'. last error: %!s(<nil>)
│ [WARNING] Running terraform apply again will remove the kubernetes add-on and attempt to create it again effectively purging previous add-on configuration
│ 
│   with module.aws-eks-addon.aws_eks_addon.coredns[0],
│   on ../modules/aws-eks-addon/main.tf line 32, in resource "aws_eks_addon" "coredns":
│   32: resource "aws_eks_addon" "coredns" {

2.Prometheus managed is OK for this region, but Grafana Managed is only available on us-east-2 (N.Virginaia) and Ireland (eu-west-1)

3.Fix kube-state-metrics (region) & cluster_autoscaler helm chart (hardcoded to eu-west-1) value = "eu-west-1" -> value = provider.aws.region

4.Add ec2_key_pair into TF to login to workers nodes 

5.UPGRADE PROCEDURE: 1.20->1.21 upgrade + add-ons upgrade with terraform apply  

```  
Screenshots:
   
- Clusters:  
<img src="https://github.com/adavarski/aws-eks-production/blob/main/eks_cluster_images/AWS-EKS-Clusters.png?raw=true" width="900">
- Cluster Overview:   
<img src="https://github.com/adavarski/aws-eks-production/blob/main/eks_cluster_images/AWS-EKS-Cluster-Overview.png?raw=true" width="900">
- Cluster Details:   
<img src="https://github.com/adavarski/aws-eks-production/blob/main/eks_cluster_images/AWS-EKS-Cluster-Configuration-Details.png?raw=true" width="900">
- Cluster:Configuration:Node Group:   
<img src="https://github.com/adavarski/aws-eks-production/blob/main/eks_cluster_images/AWS-EKS-Cluster-Configuration-Compute.png?raw=true" width="900">
- Cluster Workloads:   
<img src="https://github.com/adavarski/aws-eks-production/blob/main/eks_cluster_images/AWS-EKS-Cluster-Workloads-page1.png?raw=true" width="900">
<img src="https://github.com/adavarski/aws-eks-production/blob/main/eks_cluster_images/AWS-EKS-Cluster-Workloads-page2.png?raw=true" width="900">
   
    
## EKS Addons update
Amazon EKS doesn't modify any of your Kubernetes  add-ons when you update a cluster to newer versions.
It's important to upgrade EKS Addons [Amazon VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s), [DNS (CoreDNS)](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) and [KubeProxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) for each EKS release.

This [README](eks_cluster_addons_upgrade/README.md) guides you to update the EKS Cluster abd the addons for newer versions that matches with your EKS cluster version

Updating a EKS cluster instructions can be found in [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

## Important note
This module tested only with **Kubernetes v1.20 version**. Helm Charts addon modules aligned with k8s v1.20. If you are looking to use this code to deploy different versions of Kubernetes  then ensure Helm charts and docker images aligned with k8s version.

The `Kubernetes _version="1.20"` is the required variable in `base.tfvars`. Kubernetes  is evolving a lot, and each major version includes new features, fixes, or changes.

Always check [Kubernetes Release Notes](https://Kubernetes.io/docs/setup/release/notes/) before updating the major version. You also need to ensure your applications and Helm addons updated,
or workloads could fail after the upgrade is complete. For action, you may need to take before upgrading, see the steps in the EKS documentation.

## Notes:
If you are using an existing VPC then you may need to ensure that the following tags added to the VPC and subnet resources

Add Tags to **VPC**

```hcl-terraform
    Key = Kubernetes .io/cluster/${local.cluster_name} Value = Shared
```

Add Tags to **Public Subnets tagging** requirement

```hcl-terraform
      public_subnet_tags = {
        "Kubernetes .io/cluster/${local.cluster_name}" = "shared"
        "Kubernetes .io/role/elb"                      = "1"
      }
```

Add Tags to **Private Subnets tagging** requirement

```hcl-terraform
      private_subnet_tags = {
        "Kubernetes .io/cluster/${local.cluster_name}" = "shared"
        "Kubernetes .io/role/internal-elb"             = "1"
      }
```

For fully Private EKS clusters requires the following VPC endpoints to be created to communicate with AWS services. This module will create these endpoints if you choose to create VPC. If you are using an existing VPC then you may need to ensure these endpoints are created.

    com.amazonaws.region.aps-workspaces            - For AWS Managed Prometheus Workspace
    com.amazonaws.region.ssm                       - Secrets Management
    com.amazonaws.region.ec2
    com.amazonaws.region.ecr.api
    com.amazonaws.region.ecr.dkr
    com.amazonaws.region.logs                       – For CloudWatch Logs
    com.amazonaws.region.sts                        – If using AWS Fargate or IAM roles for service accounts
    com.amazonaws.region.elasticloadbalancing       – If using Application Load Balancers
    com.amazonaws.region.autoscaling                – If using Cluster Autoscaler
    com.amazonaws.region.s3                         – Creates S3 gateway

# PART C: Additional info
   
## Maintainer
Maintained by [A.Davarski](https://github.com/adavarski)
 
## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

