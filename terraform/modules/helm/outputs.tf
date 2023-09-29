# Helm release artifacts for local testing and validation.
output "helm_template" {
  value = var.generate_helm_template ? data.helm_template.oci-kubernetes-monitoring[0].manifest : null
}