variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "croc"
}

terraform {
  required_providers {
    aws        = {
      source  = "hc-registry.website.k2.cloud/c2devel/rockitcloud"
      version = "25.3.0"
    }
    local = {
        source  = "tf-registry.nyansq.ru/opentofu/local"
        version = "2.5.1"
    }
    ct = {
        source  = "tf-registry.nyansq.ru/poseidon/ct"
        version = "0.13.0"
    }
  }
#  backend "s3" {
#    bucket                      = "asdasd"
#    key                         = "tf-test/terraform.tfstate"
#    region                      = "us-east-1"
#    endpoint                    = "https://s3.ru-msk.k2.cloud"
#    skip_credentials_validation = true
#    skip_region_validation      = true
#    skip_metadata_api_check     = true
#    skip_s3_checksum            = true
#    skip_requesting_account_id  = true
#  }
}

provider "aws" {
  endpoints {
    ec2 = "https://ec2.ru-msk.k2.cloud"
  }
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_region_validation = true

  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


provider "aws" {
  alias = "noregion"
  endpoints {
    s3 = "https://s3.ru-msk.k2.cloud"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  insecure   = false
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-1"
}
