# Las credenciales se resuelven mediante la cadena estándar de AWS.
provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  resource_name = "${var.github_username}-${substr(data.aws_caller_identity.current.account_id, 0, 8)}"

  common_tags = {
    Name      = local.resource_name
    ManagedBy = "Terraform"
  }
}
