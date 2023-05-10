variable "instance_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the SSO Instance under which the operation will be executed"
}

variable "name" {
  type        = string
  description = "The name of the Permission Set"
}

variable "description" {
  type        = string
  description = "The description of the Permission Set"
}

variable "duration" {
  type        = number
  description = "The length of time that the application user sessions are valid."
  default     = 8
}

variable "policies" {
  type        = list(string)
  description = "The IAM managed policy Amazon Resource Names (ARNs) to be attached to the Permission Set."
  default     = []
}
