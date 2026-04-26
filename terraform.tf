terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = ">= 3.85.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.42.0"
    }
  }
}
