module "network" {
  source = "./modules/network"

  stack_prefix = local.stack_prefix
  region       = var.region

  vpc     = var.vpc
  subnets = var.subnets
}

module "iam" {
  source = "./modules/iam"

  stack_prefix = local.stack_prefix

  self_account_id = data.aws_caller_identity.self.account_id
  sso_account_id  = data.aws_caller_identity.sso.account_id
  allow_src_ip    = var.allow_src_ip
  s3_bucket_logs  = module.s3.buckets.logs
}

module "s3" {
  source = "./modules/s3"

  stack_prefix = local.stack_prefix
}

module "crt_wildcard" {
  source = "./modules/certificate"

  stack_prefix = local.stack_prefix

  domain = var.ecs_web.domain
}

module "ecs_web" {
  source = "./modules/ecs_stack"

  stack_prefix = local.stack_prefix
  region       = var.region

  ecs                = var.ecs_web
  execution_role_arn = module.iam.roles.ecs_service.arn
  task_role_arn      = module.iam.roles.ecs_task.arn
  vpc_id             = module.network.vpc.id
  alb_subnets        = module.network.subnets.public
  ecs_subnets        = module.network.subnets.private
  s3_bucket_logs_id  = module.s3.buckets.logs.id
  certificate_arn    = module.crt_wildcard.certificate.arn
}

module "cloudfront" {
  source = "./modules/cloudfront_stack"

  stack_prefix = local.stack_prefix
  region       = var.region

  elb_id         = module.ecs_web.alb.id
  elb_domain     = module.ecs_web.alb.domain
  s3_bucket_logs = module.s3.buckets.logs
}