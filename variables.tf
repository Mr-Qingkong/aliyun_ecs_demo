variable "instance_number" {
  default = 1
}

variable "instance_type" {
  default = "ecs.n2.small"
}

variable "key_pair_name" {
  default = "my_public_key"
}


variable "instance_name" {
  default = "tf_ecs_test"
}
