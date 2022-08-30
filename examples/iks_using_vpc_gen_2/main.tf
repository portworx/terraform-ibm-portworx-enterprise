terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

provider "ibm" {
    region = "us-east"
}

resource "ibm_is_vpc" "vpc" {
  name = "sudas-iks-vpc"
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "sudas-iks-sn-01"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "us-east-1"
  total_ipv4_address_count = 256
}

resource "ibm_is_subnet" "subnet2" {
  name                     = "sudas-iks-sn-02"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "us-east-2"
  total_ipv4_address_count = 256
}

resource "ibm_is_subnet" "subnet3" {
  name                     = "sudas-iks-sn-03"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "us-east-3"
  total_ipv4_address_count = 256
}

data "ibm_resource_group" "resource_group" {
  name = "Portworx-Dev"
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "sudas-iks-k8s-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  flavor            = "bx2.4x16"
  # This worker_count is per zone
  worker_count      = 1
  resource_group_id = data.ibm_resource_group.resource_group.id
  zones {
        subnet_id = ibm_is_subnet.subnet1.id
        name      = "us-east-1"
    }
  zones {
        subnet_id = ibm_is_subnet.subnet2.id
        name      = "us-east-2"
    }
  zones {
        subnet_id = ibm_is_subnet.subnet3.id
        name      = "us-east-3"
    }
}
