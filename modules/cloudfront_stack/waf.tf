resource "aws_waf_ipset" "company" {
  name = "Company"

  ip_set_descriptors {
    type  = "IPV4"
    value = "60.125.192.191/32"
  }
}

resource "aws_waf_rule" "match_company" {
  name        = "matchCompany"
  metric_name = "matchCompany"

  predicates {
    data_id = aws_waf_ipset.company.id
    negated = false
    type    = "IPMatch"
  }

  depends_on = [
    aws_waf_ipset.company
  ]
}

resource "aws_waf_web_acl" "allow_only_company" {
  name        = "allowOnlyCompany"
  metric_name = "allowOnlyCompany"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_waf_rule.match_company.id
    type     = "REGULAR"
  }

  depends_on = [
    aws_waf_rule.match_company
  ]
}