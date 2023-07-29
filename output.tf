output "vpc_id" {
  value = module.vpc.vpc_id
}

output "load_balancer_dns_name" {
  value = module.load_balancer.load_balancer_dns_name
}

output "autoscaling_group_name" {
  value = module.autoscaling.autoscaling_group_name
}
