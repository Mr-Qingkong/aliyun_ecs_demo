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
  user_data = data.cloudinit_config.cloudiac.rendered

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
  vars = {
      port = 80
      ansible_user = "root"
    }
  )
}
