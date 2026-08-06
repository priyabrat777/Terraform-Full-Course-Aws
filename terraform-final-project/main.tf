module "kms" {
  source = "./modules/kms"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "network" {
  source = "./modules/network"

  providers = {
    aws           = aws
    aws.secondary = aws.dr
  }

  name_prefix             = local.name_prefix
  tags                    = local.common_tags
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  availability_zones      = var.availability_zones
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  enable_vpc_endpoints    = var.enable_vpc_endpoints
  enable_secondary_vpc    = var.enable_secondary_vpc
  secondary_vpc_cidr      = var.secondary_vpc_cidr
  alb_ingress_cidr_blocks = var.alb_ingress_cidr_blocks
  allowed_ssh_cidr_blocks = var.allowed_ssh_cidr_blocks
}

module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "secrets" {
  source = "./modules/secrets"

  name_prefix = local.name_prefix
  db_username = var.db_username
  kms_key_arn = module.kms.key_arns["secrets"]
  application_map = {
    environment = var.environment
    region      = var.aws_region
    vpc_id      = module.network.vpc_id
  }
  tags = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  name_prefix           = local.name_prefix
  kms_key_arn           = module.kms.key_arns["app"]
  log_kms_key_arn       = module.kms.key_arns["logs"]
  private_subnet_ids    = module.network.private_subnet_ids
  efs_security_group_id = module.network.security_group_ids.efs
  enable_cloudfront     = var.enable_cloudfront
  tags                  = local.common_tags
}

module "database" {
  source = "./modules/database"

  name_prefix                = local.name_prefix
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = module.secrets.db_password
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  deletion_protection        = var.enable_rds_deletion_protection
  private_subnet_ids         = module.network.private_subnet_ids
  database_security_group_id = module.network.security_group_ids.database
  kms_key_arn                = module.kms.key_arns["app"]
  tags                       = local.common_tags
}

module "loadbalancers" {
  source = "./modules/loadbalancers"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  alb_security_group = module.network.security_group_ids.alb
  tags               = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  name_prefix             = local.name_prefix
  instance_type           = var.instance_type
  key_name                = var.key_name
  private_subnet_ids      = module.network.private_subnet_ids
  public_subnet_ids       = module.network.public_subnet_ids
  app_security_group_id   = module.network.security_group_ids.app
  admin_security_group_id = module.network.security_group_ids.admin
  instance_profile_name   = module.iam.ec2_instance_profile_name
  target_group_arns       = [module.loadbalancers.app_target_group_arn]
  asg_min_size            = var.asg_min_size
  asg_desired_capacity    = var.asg_desired_capacity
  asg_max_size            = var.asg_max_size
  bastion_instance_count  = var.bastion_instance_count
  app_bucket_name         = module.storage.bucket_names["app"]
  tags                    = local.common_tags
}

module "containers" {
  source = "./modules/containers"

  name_prefix             = local.name_prefix
  private_subnet_ids      = module.network.private_subnet_ids
  ecs_security_group_id   = module.network.security_group_ids.ecs
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn           = module.iam.ecs_task_role_arn
  container_image         = var.container_image
  desired_count           = var.ecs_desired_count
  enable_ecs_service      = var.enable_ecs_service
  enable_eks_cluster      = var.enable_eks_cluster
  kms_key_arn             = module.kms.key_arns["app"]
  tags                    = local.common_tags
}

module "serverless" {
  source = "./modules/serverless"

  name_prefix            = local.name_prefix
  enabled                = var.enable_lambda
  lambda_runtime         = var.lambda_runtime
  lambda_timeout         = var.lambda_timeout
  lambda_memory_size     = var.lambda_memory_size
  log_retention_days     = var.log_retention_days
  source_bucket_id       = module.storage.bucket_names["artifacts"]
  source_bucket_arn      = module.storage.bucket_arns["artifacts"]
  destination_bucket_id  = module.storage.bucket_names["app"]
  destination_bucket_arn = module.storage.bucket_arns["app"]
  kms_key_arn            = module.kms.key_arns["app"]
  tags                   = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix                 = local.name_prefix
  aws_region                  = var.aws_region
  alert_email                 = var.alert_email
  log_retention_days          = var.log_retention_days
  alb_arn_suffix              = module.loadbalancers.alb_arn_suffix
  alb_target_group_arn_suffix = module.loadbalancers.app_target_group_arn_suffix
  autoscaling_group_name      = module.compute.autoscaling_group_name
  rds_instance_id             = module.database.rds_instance_id
  lambda_function_name        = module.serverless.lambda_function_name
  app_bucket_name             = module.storage.bucket_names["app"]
  log_kms_key_arn             = module.kms.key_arns["logs"]
  tags                        = local.common_tags
}

module "dns" {
  source = "./modules/dns"

  domain_name        = var.domain_name
  create_zone        = var.create_route53_zone
  create_record      = var.create_dns_record
  alb_dns_name       = module.loadbalancers.alb_dns_name
  alb_zone_id        = module.loadbalancers.alb_zone_id
  cloudfront_domain  = module.storage.cloudfront_domain_name
  cloudfront_zone_id = module.storage.cloudfront_hosted_zone_id
  tags               = local.common_tags
}
