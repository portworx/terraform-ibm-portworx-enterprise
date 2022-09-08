provider "ibm" {
  region = var.region
}
  provider "kubernetes" {
    config_path =var.kubeconfig_path
    config_context = var.k8s_context
  }