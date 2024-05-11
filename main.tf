module "vpc" {
  source                  = "./modules/vpc"
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private-app-subnet-cidr = var.private-app-subnet-cidr
  private-db-subner-cidr  = var.private-db-subner-cidr
  availability_zone       = var.availability_zone
}

locals {
  subnet_ids = [for subnet in module.vpc.sg_id : subnet.id]
}
locals {
  private_app_subnet_id = [for subnet in module.vpc.private_app_subnet_id : subnet.id]
}
module "rds" {
  source            = "./modules/rds"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = local.subnet_ids
  availability_zone = var.availability_zone
}
module "web" {
  source     = "./modules/web"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = local.private_app_subnet_id
}
module "app" {
  source     = "./modules/app"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = local.private_app_subnet_id
}
output "private_app_subnet_id" {
  value = local.private_app_subnet_id[0]
}
output "private_db_subnet" {
  # value = length(module.vpc.sg_id)
  value = local.subnet_ids
  # value = { for key, resource in module.vpc.sg_id : key => resource.id }
}
