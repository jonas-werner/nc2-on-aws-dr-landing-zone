provider "aws" {
  region = var.vpc1_region
}

provider "aws" {
  alias  = "vpc2"
  region = var.vpc2_region
} 