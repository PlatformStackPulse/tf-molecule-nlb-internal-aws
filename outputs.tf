output "nlb_arn" {
  description = "ARN of the NLB"
  value       = module.nlb.arn
}

output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = module.nlb.dns_name
}

output "nlb_zone_id" {
  description = "Route53 zone ID of the NLB"
  value       = module.nlb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.target_group.arn
}
