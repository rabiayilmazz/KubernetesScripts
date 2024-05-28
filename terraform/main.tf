# terraform

## Version.tf

terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = ">= 1.20.0"
    }
  }
}

## cce.tf

                                                                       
provider "huaweicloud" {
  region     = "tr-west-1"
  access_key = "AK"
  secret_key = "SK"
  enterprise_project_id = "EP_ID"
}

resource "huaweicloud_vpc" "myvpc" {
  name = "myvpc"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "mysubnet" {
  name          = "mysubnet"
  cidr          = "192.168.0.0/16"
  gateway_ip    = "192.168.0.1"

  //dns is required for cce node installing
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.21.250"
  vpc_id        = huaweicloud_vpc.myvpc.id
}

resource "huaweicloud_vpc_eip" "myeip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "mybandwidth"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_cce_cluster" "mycce" {
  name                   = "mycce"
  flavor_id              = "cce.s1.small"
  vpc_id                 = huaweicloud_vpc.myvpc.id
  subnet_id              = huaweicloud_vpc_subnet.mysubnet.id
  container_network_type = "overlay_l2"
  eip                    = huaweicloud_vpc_eip.myeip.address // If you choose not to use EIP, skip this line.
}


data "huaweicloud_availability_zones" "myaz" {}

resource "huaweicloud_compute_keypair" "mykeypair" {
  name       = "mykeypair"
}

resource "huaweicloud_cce_node_pool" "my_node_pool" {
  cluster_id = huaweicloud_cce_cluster.mycce.id
  name       = "my-node-pool"
  flavor_id  = "c7n.xlarge.2"
  os         = "EulerOS 2.5"

  initial_node_count = 2
  min_node_count     = 2
  max_node_count     = 5

  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  key_pair          = huaweicloud_compute_keypair.mykeypair.name

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
  tags = {
    status = "running"
    time = "2025-06-06"
  }
}
