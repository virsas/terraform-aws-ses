# Terraform AWS SES Module

A Terraform module for verifying a domain identity with [Amazon Simple Email Service (SES)](https://docs.aws.amazon.com/ses/latest/dg/Welcome.html), enabling Easy DKIM signing for that domain and configuring a custom MAIL FROM subdomain for bounce and complaint handling.

## Features

- **Domain Identity**: Registers a domain as an SES identity and exposes the TXT verification token required to prove ownership.
- **Easy DKIM**: Enables DKIM signing for the domain and returns the three CNAME tokens that must be published in DNS.
- **Custom MAIL FROM**: Configures a MAIL FROM subdomain built from a configurable prefix and the verified domain, improving SPF alignment and DMARC results.
- **DNS Agnostic**: Publishes all verification data as outputs so records can be created in Route53 or any external DNS provider.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Verify a domain with the default `bounces` MAIL FROM prefix:

```hcl
module "ses" {
  source = "git::https://github.com/virsas/terraform-aws-ses.git?ref=v1.1"

  domain = "virsas.com"
}
```

### Advanced Example (Custom MAIL FROM & DNS Records)

Use a custom MAIL FROM prefix and publish the verification, DKIM and MAIL FROM records in Route53:

```hcl
module "ses" {
  source = "git::https://github.com/virsas/terraform-aws-ses.git?ref=v1.1"

  domain           = "virsas.com"
  mail_from_prefix = "mail"
}

resource "aws_route53_record" "ses_verification" {
  zone_id = "Z123456789ABCDEF"
  name    = "_amazonses.${module.ses.domain}"
  type    = "TXT"
  ttl     = 600
  records = [module.ses.verification_token]
}

resource "aws_route53_record" "ses_dkim" {
  count = 3

  zone_id = "Z123456789ABCDEF"
  name    = "${module.ses.dkim_tokens[count.index]}._domainkey.${module.ses.domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${module.ses.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = "Z123456789ABCDEF"
  name    = "mail.${module.ses.domain}"
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.eu-west-1.amazonses.com"]
}

resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id = "Z123456789ABCDEF"
  name    = "mail.${module.ses.domain}"
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com -all"]
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_ses_domain_identity.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity) | resource |
| [aws_ses_domain_dkim.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim) | resource |
| [aws_ses_domain_mail_from.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_mail_from) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain name to verify with SES (e.g. `virsas.com`). | `string` | n/a | yes |
| <a name="input_mail_from_prefix"></a> [mail\_from\_prefix](#input\_mail\_from\_prefix) | The prefix used to build the custom MAIL FROM subdomain, resulting in `<mail_from_prefix>.<domain>`. | `string` | `"bounces"` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_identity_arn"></a> [domain\_identity\_arn](#output\_domain\_identity\_arn) | The ARN of the SES domain identity. |
| <a name="output_dkim_tokens"></a> [dkim\_tokens](#output\_dkim\_tokens) | The list of DKIM tokens used to build the `_domainkey` CNAME records. |
| <a name="output_verification_token"></a> [verification\_token](#output\_verification\_token) | The verification token published as the `_amazonses` TXT record. |
| <a name="output_domain"></a> [domain](#output\_domain) | The verified SES domain name. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
