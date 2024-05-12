variable "context" {
  type = object({
    enabled             = optional(bool, true)
    namespace           = optional(string, null)
    tenant              = optional(string, null)
    environment         = optional(string, null)
    stage               = optional(string, null)
    name                = optional(string, null)
    delimiter           = optional(string, null)
    attributes          = optional(list(string), [])
    tags                = optional(map(string), {})
    additional_tag_map  = optional(map(string), {})
    regex_replace_chars = optional(string, null)
    label_order         = optional(list(string), [])
    id_length_limit     = optional(number, null)
    label_key_case      = optional(string, null)
    label_value_case    = optional(string, null)
    descriptor_formats  = optional(map(string), {})
    labels_as_tags      = optional(list(string), ["unset"])
  })

  description = "Object wrapper for the context map of the null label module. See the null label module for more information."
}

variable "create_lambda" {
  type = bool
  default = false
}

variable "lambda_image_tag" {
  type = string
  default = "latest"
}