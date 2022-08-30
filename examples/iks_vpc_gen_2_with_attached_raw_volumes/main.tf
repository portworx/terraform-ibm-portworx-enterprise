module "attach_block_volumes_on_iks_nodes" {
    source = "./iks-attach-block-storage"
    region = var.region
    iks_cluster_name = var.iks_cluster_name
    capacity = var.capacity
    resource_group = var.resource_group
}

module "portworx-enterprise" {
    source = "github.com/portworx/terraform-ibm-portworx-enterprise"
    //TODO: Find a way to read the ibm_api_key from environment variable
    ibmcloud_api_key = var.ibmcloud_api_key
    //TODO: Find a way to generate unique_id
    unique_id = "sudas-px"
    cluster_name = var.iks_cluster_name
    resource_group = var.resource_group
    kube_config_path = ".kubeconfig"
}
