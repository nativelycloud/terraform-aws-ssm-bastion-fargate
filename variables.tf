variable "name" {
  type = string
  description = "The name of this stack. This will be used in the names of all resources created by this module"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC where the bastion should run"
}

variable "subnets" {
  type = list(string)
  description = "The IDs of the subnets where the bastion should run"
}

variable "security_groups" {
  type    = list(string)
  default = []
  description = "The IDs of the security groups to attach to the bastion task"
}

variable "task_cpu" {
  type        = number
  default     = 256
  description = "Number of CPU units to allocate for the bastion task"
}

variable "task_memory" {
  type        = number
  default     = 512
  description = "Amount of memory (in MiB) to allocate for the bastion task"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Number of instances of the bastion task to run"
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Whether to assign a public IP to the bastion task. If false, you will need a NAT gateway or at least ECR, SSM & SSM Messages VPC endpoints"
}

variable "create_default_security_group" {
  type        = bool
  default     = true
  description = "Whether to create a default security group allowing all outbound traffic for the bastion task. If false, you will need to provide your own in `security_groups`"
}