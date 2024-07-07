variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type    = list(string)
  default = []
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
  description = "Whether to assign a public IP to the bastion task. If false, you will need a NAT gateway or at least SSM & ECR VPC endpoints"
}

variable "create_default_security_group" {
  type        = bool
  default     = true
  description = "Whether to create a default security group allowing all outbound traffic for the bastion task. If false, you will need to provide your own in `security_groups`"
}