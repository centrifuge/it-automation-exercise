variable "extra_script_src" {
  description = "Additional script-src hosts allowed on every target."
  type        = list(string)
  default     = []
}

variable "extra_style_src" {
  description = "Additional style-src hosts allowed on every target."
  type        = list(string)
  default     = []
}

variable "extra_font_src" {
  description = "Additional font-src hosts allowed on every target."
  type        = list(string)
  default     = []
}

variable "extra_frame_src" {
  description = "Additional frame-src hosts allowed on every target."
  type        = list(string)
  default     = []
}
