terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
   // alicloud = {
   //   source = "aliyun/alicloud"
  //}
  }
}

provider "alicloud" {}

provider "ansible" {}

locals {
  common_vars = {
    ansible_user = "root"
    pk_file      = "/root/.ssh/id_rsa"
  }

  num_of_servers = {
    web = 1
  }
}

resource "alicloud_key_pair" "publickey" {
  key_pair_name   = var.key_pair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCv+esXIkP5E+ZZSEryZ0eLO9adL4Khi82kZLcVtezhS5PKd6gOvfrnZ4nMCsPWOe/ps43mpAj49e78td34nnp6Yy8Mo9tnClGkbl8haACfJDxA2Kty9gMOBU1kgtUEQg2c4RDXS4QIvbHJjiBZg7+tXFIHyiNiD/guAam9L4sLSzb2IF+xuxx97ZJUyzs+SzcZClTLBMVE+Vhi6R/k5PyqAFhkc4HNdr/PavPjxTJDiyUIQGQphNkg1xBbRy0FrsDguoakd+jLCOxPCdLSqdHzYJJf1HTaajhb39qsLfSJcya3BMXN7bmeoPZXoGIBoIF0tfBIQ9vI7J6MNsLokgGUtDXahLVWiwLjEpapQvfdWgvc7LGanVk4QavTJFwdExsGOmdcsgjIeLHk5dloSrKIvReWFWitew5wXiKNCzBGzgMq7u9uWrU3Jg8FZ8eo2dRQgToTSWQtjDw/P1N6FmVz7fg3Ud8xwfdNT5n2et/GP7sR4H7uiQvJUssPwpwXnV0= root@1607371b97b6"
}

resource "alicloud_vpc" "vpc" {
  vpc_name       = "tf_test_foo"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.0.0/21"
  zone_id = "cn-beijing-b"
}

resource "alicloud_security_group" "default" {
  name = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_instance" "instance" {
  # cn-beijing
  availability_zone = "cn-beijing-b"
  security_groups = alicloud_security_group.default.*.id
  # series III
  instance_type        = var.instance_type
  system_disk_category = "cloud_efficiency"
  image_id             = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  count                = var.instance_number
  instance_name        = var.instance_name
  vswitch_id = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = 1
  key_name = alicloud_key_pair.publickey.key_pair_name
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "ansible_host" "web" {
  count                = var.instance_number
  inventory_hostname = alicloud_instance.instance[count.index].public_ip
  groups             = ["web"]
  vars = merge(local.common_vars,
    {
      port = 80
    }
  )
}
