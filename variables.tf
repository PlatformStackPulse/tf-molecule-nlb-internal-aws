variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the NLB (min 2)"
  type        = list(string)
}

variable "listener_port" {
  description = "Port the NLB listens on"
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Port the targets listen on"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target type (instance, ip)"
  type        = string
  default     = "instance"
}
