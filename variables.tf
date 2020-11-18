variable "access_key" {
  type        = string
  description = "Access key"
  default     = ""
}

variable "secret_key" {
  type        = string
  description = "Secret key"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region"
  default     = "us-east-1"
}

variable "amis" {
  default = {
    us-east-1 = "ami-00ddb0e5626798373"
  }
}

variable "name_tag" {
  type        = string
  description = "NAME tag for all"
  default     = "PlayQ-2019"
}

variable "type_tag" {
  type        = string
  description = "TYPE tag for all"
  default     = "webserver"
}
