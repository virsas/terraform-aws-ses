variable "domain" {
  description = "The domain name to verify with SES (e.g., virsas.com)."
  type        = string
}
variable "mail_from_prefix" {
  description = "The prefix for the MAIL FROM subdomain."
  type        = string
  default     = "bounces"
}