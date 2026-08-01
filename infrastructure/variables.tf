variable "aws_region" {
  description = "AWS region where the infrastructure is created."
  type        = string
  nullable    = false
}

variable "github_username" {
  description = "Participant's lowercase GitHub username."
  type        = string
  nullable    = false

  validation {
    condition = can(
      regex(
        "^[a-z0-9](?:[a-z0-9-]{0,37}[a-z0-9])?$",
        var.github_username
      )
    )

    error_message = "github_username must be 1-39 lowercase characters using only letters, numbers, and hyphens."
  }
}
