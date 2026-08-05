# Terraform Final Project

This capstone project consolidates the Terraform and AWS concepts covered across the course lessons into one production-style AWS infrastructure project. It is organized by infrastructure domain instead of lesson number and is intended to be deployed as a single root module after you provide backend settings, AWS credentials, and any environment-specific variable values.

The existing lesson folders are intentionally untouched.

## Project Overview

The architecture provisions a tagged, multi-tier application platform:

- A primary VPC with public and private subnets, route tables, an internet gateway, optional NAT gateway, NACLs, security groups, VPC endpoints, and optional cross-region VPC peering.
- An ALB and NLB at the edge.
- EC2 application instances managed by a launch template and Auto Scaling group, plus optional standalone admin EC2 instances.
- S3 buckets for application files, artifacts, logs, and audit data, plus CloudFront for static content.
- RDS MySQL in private subnets and a DynamoDB metadata table.
- EFS for shared application storage.
- IAM roles, policies, groups, optional users, and instance profiles.
- KMS keys for application, log, and secrets encryption.
- Secrets Manager and SSM Parameter Store for generated credentials and configuration.
- Lambda triggered by S3 and wired to SQS.
- ECR, ECS Fargate, and an optional EKS cluster.
- CloudWatch logs, metric filters, alarms, dashboard, SNS notifications, CloudTrail, and AWS Config rules.
- Optional Route53 hosted zone and ALB alias record.
- An AWS Resource Group that discovers project resources through common tags.

## Folder Structure

```text
terraform-final-project/
  backend.tf                 # S3 backend declaration
  backend.hcl.example        # Backend config placeholders
  providers.tf               # Primary and DR AWS providers
  versions.tf                # Terraform and provider constraints
  variables.tf               # Root input variables and validation
  locals.tf                  # Naming and common tags
  main.tf                    # Root module composition
  outputs.tf                 # Root outputs
  terraform.tfvars.example   # Example environment values
  network/                   # VPC, subnets, IGW, NAT, routes, NACL, SGs, endpoints, peering
  loadbalancers/             # ALB, NLB, target groups, listeners
  compute/                   # EC2, launch template, Auto Scaling
  storage/                   # S3, CloudFront, EFS
  database/                  # RDS and DynamoDB
  iam/                       # IAM roles, policies, groups, optional users, instance profiles
  kms/                       # KMS keys and aliases
  secrets/                   # Secrets Manager, generated password, SSM parameters
  serverless/                # Lambda, S3 notification, SQS
  containers/                # ECR, ECS, optional EKS
  monitoring/                # CloudWatch, SNS, CloudTrail, AWS Config
  dns/                       # Optional Route53 zone and record
  resourcegroups.tf          # Tag-based AWS Resource Group
  modules/remote-state-consumer/ # Example remote state consumer
  examples/                  # Static site files and provisioner example
  scripts/                   # EC2 user data and Lambda source
```

## Prerequisites

- Terraform `>= 1.6.0`.
- AWS CLI configured for the target account.
- AWS credentials with permissions for VPC, EC2, ELB, Auto Scaling, S3, CloudFront, RDS, DynamoDB, IAM, KMS, Secrets Manager, SSM, Lambda, SQS, ECR, ECS, EKS if enabled, CloudWatch, SNS, CloudTrail, AWS Config, and Route53 if enabled.
- An S3 bucket for Terraform state.
- A DynamoDB table for Terraform state locking.

## Backend Setup

This project uses only an S3 remote backend:

```hcl
terraform {
  backend "s3" {}
}
```

Copy `backend.hcl.example` to a local backend config file outside version control or edit the values during initialization:

```hcl
bucket         = "replace-with-your-terraform-state-bucket"
key            = "terraform-final-project/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "replace-with-your-terraform-lock-table"
encrypt        = true
```

Initialize with:

```bash
terraform init -backend-config=backend.hcl
```

## Variables

Start from `terraform.tfvars.example` and adjust values for your account:

- `aws_region`, `secondary_region`: Primary and provider-alias regions.
- `project_name`, `environment`, `owner`, `cost_center`, `application`, `additional_tags`: Naming and tagging inputs.
- `vpc_cidr`, `public_subnet_cidrs`, `private_subnet_cidrs`, `availability_zones`: Network layout.
- `enable_nat_gateway`, `single_nat_gateway`, `enable_vpc_endpoints`, `enable_secondary_vpc`: Network feature toggles.
- `alb_ingress_cidr_blocks`, `allowed_ssh_cidr_blocks`: Ingress controls.
- `instance_type`, `key_name`, `asg_min_size`, `asg_desired_capacity`, `asg_max_size`, `bastion_instance_count`: EC2 and ASG sizing.
- `db_name`, `db_username`, `db_instance_class`, `db_allocated_storage`, `enable_rds_deletion_protection`: Database settings.
- `alert_email`, `log_retention_days`: Monitoring and notifications.
- `enable_lambda`, `lambda_runtime`, `lambda_timeout`, `lambda_memory_size`: Serverless settings.
- `enable_cloudfront`, `enable_ecs_service`, `container_image`, `ecs_desired_count`, `enable_eks_cluster`: Static content and container settings.
- `domain_name`, `create_route53_zone`, `create_dns_record`: Optional DNS settings.

Sensitive values are marked sensitive where appropriate. The database password is generated with Terraform and stored in Secrets Manager and SSM Parameter Store.

## Deployment Steps

Do not run these until the backend bucket, DynamoDB lock table, credentials, and variable values are ready.

```bash
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform destroy -var-file=terraform.tfvars
```

For a production environment, consider enabling RDS deletion protection and adding literal `prevent_destroy = true` lifecycle blocks to critical stateful resources after the training destroy workflow is no longer needed.

## Architecture

Traffic enters through the public ALB and is forwarded to an Auto Scaling group in private subnets. Instances bootstrap with `templatefile` user data and run a small Nginx page. Private subnets can reach AWS services through VPC endpoints and, when enabled, outbound internet through NAT.

The application tier can read configuration from SSM and Secrets Manager, write to encrypted S3 buckets, and use RDS, DynamoDB, and EFS for state. CloudFront serves static files uploaded to S3 through `fileset` and `for_each`.

The serverless path processes S3 uploads under `incoming/`, invokes Lambda, writes derived metadata to the application bucket, and includes SQS wiring for queue-driven events.

The container path creates ECR and ECS Fargate resources by default. EKS is present as an optional advanced path because it is more expensive and slower to create.

Monitoring includes SNS alerts, CloudWatch alarms, a dashboard, log metric filters, CloudTrail audit logging, and AWS Config managed rules.

## Course Concept Coverage

This project demonstrates:

- Terraform settings, provider constraints, S3 backend, and provider aliases.
- Variables, validation, nullable inputs, sensitive inputs, tfvars usage, locals, outputs, and common tags.
- Data sources including AMI, caller identity, region, availability zones, IAM policy documents, archive file, Route53 zone, and remote state in `modules/remote-state-consumer`.
- Resources across networking, compute, load balancing, storage, database, IAM, KMS, secrets, serverless, containers, DNS, monitoring, audit, and compliance.
- `count`, `for_each`, `dynamic` blocks, `depends_on`, `lifecycle`, splat expressions, for expressions, conditionals, and functions such as `merge`, `lookup`, `concat`, `try`, `regex`, `replace`, `lower`, `substr`, `fileset`, `filemd5`, `jsonencode`, `templatefile`, and `cidrsubnet`.
- Provisioner awareness in `examples/provisioner-last-resort`, isolated from the production path because provisioners should be a last resort.

## Customization

- Change regions with `aws_region` and `secondary_region`.
- Add subnets by appending CIDR blocks to `public_subnet_cidrs` and `private_subnet_cidrs`.
- Increase EC2 capacity with `asg_*` variables.
- Add optional admin EC2 instances with `bastion_instance_count` and restrict SSH with `allowed_ssh_cidr_blocks`.
- Enable or disable NAT gateways, VPC endpoints, Lambda, CloudFront, ECS, EKS, secondary VPC peering, and DNS through feature flags.
- Use your own ECS image by changing `container_image`.

## Troubleshooting

- Backend initialization fails: verify the S3 state bucket, DynamoDB lock table, region, and IAM permissions.
- S3 bucket name conflict: bucket names are globally unique; change `project_name` or environment to alter generated names.
- ALB returns 503: wait for ASG instances to pass health checks and verify private subnet routing.
- ECS tasks do not start: confirm NAT or VPC endpoints exist and the image is reachable.
- RDS takes time: database creation commonly takes several minutes.
- SNS emails do not arrive: confirm the SNS subscription from the email AWS sends.
- AWS Config recorder conflicts: only one configuration recorder can exist per region per account; import or disable existing account-level Config resources before deploying this training stack.
- EKS is slow or costly: keep `enable_eks_cluster = false` unless you specifically want to exercise the EKS path.
