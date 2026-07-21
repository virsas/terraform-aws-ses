resource "aws_ses_domain_identity" "vss" {
  domain = var.domain
}
resource "aws_ses_domain_dkim" "vss" {
  domain = aws_ses_domain_identity.vss.domain
}
resource "aws_ses_domain_mail_from" "vss" {
  domain           = aws_ses_domain_identity.vss.domain
  mail_from_domain = "${var.mail_from_prefix}.${var.domain}"
}