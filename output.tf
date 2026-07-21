output "domain_identity_arn" {
  value = aws_ses_domain_identity.vss.arn
}
output "dkim_tokens" {
  value = aws_ses_domain_dkim.vss.dkim_tokens
}
output "verification_token" {
  value = aws_ses_domain_identity.vss.verification_token
}
output "domain" {
  value = aws_ses_domain_identity.vss.domain
}