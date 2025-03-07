variable "domain" {
  description = "The domain name for the ACM certificate"
  type        = string
}

variable "github_repo" {
  description = "The GitHub organization/repository name. Note that the organization name must have the same case as it appears in the URL, eg `TastyDucks/foobar`"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-1"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}
