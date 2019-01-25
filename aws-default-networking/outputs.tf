output "vault_cluster_instance_ids" {
  description = "list of instance IDs of the created vault cluster "
  value       = ["${module.terraform-aws-vault.vault_cluster_instance_ids}"]
}

output "vault_cluster_instance_ips" {
  description = "list of ip addresses for the instances in the created vault cluster "
  value       = ["${module.terraform-aws-vault.vault_cluster_instance_ips}"]
}

output "cluster_server_role" {
  description = "The role ID to attach policies to for the cluster instances"
  value       = "${module.terraform-aws-vault.cluster_server_role}"
}
output "consul_cluster_instance_ids" {
  description = "list of instance IDs of the created consul cluster "
  value       = ["${module.terraform-aws-vault.consul_cluster_instance_ids}"]
}

output "consul_cluster_instance_ips" {
  description = "list of ip addresses for the instances in the created consul cluster "
  value       = ["${module.terraform-aws-vault.consul_cluster_instance_ips}"]
}
output "elb_dns" {
  description = "DNS name for the ELB if created"
  value = "${module.terraform-aws-vault.elb_dns}"
}

output "private_key_path" {
  description = "Private key for accessing servers via SSH"
  value = "${local_file.private_key.filename}"
}
