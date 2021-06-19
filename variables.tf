variable "instance_number" {
  default = 1
  description = "创建ecs服务器数据量，默认值为一台"
}

variable "instance_type" {
  default = "ecs.n2.small"
  description = "创建ecs服务器实例规格"
}

variable "key_pair_name" {
  default = "test_key"
  description = "配置公钥访问，公钥在阿里云服务上展示的名称"
}


variable "instance_name" {
  default = "tf_ecs_test"
  description = "创建的ecs服务器名称"
}
