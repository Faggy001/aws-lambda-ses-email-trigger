variable "aws_region" {
  description = "AWS region"
  default     = "ca-central-1"
}

variable "sender_email" {
  description = "SES verified sender email"
  type        = string
}

variable "recipient_email" {
  description = "Email to receive messages"
  type        = string
}

variable "iam_user" {
  description = "IAM user to check access keys for"
  type        = string
}

variable "expiry_days" {
  description = "Key expiry threshold in days"
  type        = number
  default     = 90
}