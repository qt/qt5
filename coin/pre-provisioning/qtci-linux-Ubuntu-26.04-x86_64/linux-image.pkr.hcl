packer {
  required_version = ">= 1.14.0"

  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "distro_name" {
  type = string
}
variable "distro_version" {
  type = string
}
variable "image_prefix" {
  type = string
}
variable "arch" {
  type = string
}
variable "minimal_index" {
  type = string
}
variable "custom_index" {
  type = string
}
variable "iso_path" {
  type = string
}
variable "project_dir" {
  type = string
}
variable "artifact_dir" {
  type = string
}
variable "disk_size" {
  type = string
}
variable "cpus" {
  type = number
}
variable "memory_mb" {
  type = number
}
variable "ssh_username" {
  type = string
}
variable "ssh_password" {
  type      = string
  sensitive = true
}

locals {
  image_base_name = "${var.image_prefix}-${var.distro_name}-${var.distro_version}-${var.arch}"
  image_50_name   = "${local.image_base_name}-${var.minimal_index}"
  image_51_name   = "${local.image_base_name}-${var.custom_index}"

  image_50_path = "${var.artifact_dir}/${local.image_50_name}"
  image_51_path = "${var.artifact_dir}/${local.image_51_name}"
  image_51_seed = "/tmp/${local.image_51_name}-seed.qcow2"

  stage_50_output = "/tmp/packer-output-${var.minimal_index}"
  stage_51_output = "/tmp/packer-output-${var.custom_index}"
}

source "qemu" "stage_50" {
  vm_name          = local.image_50_name
  output_directory = local.stage_50_output

  iso_url      = var.iso_path
  iso_checksum = "none"

  accelerator    = "kvm"
  qemu_binary    = "qemu-system-x86_64"
  format         = "qcow2"
  disk_size      = var.disk_size
  disk_interface = "virtio"
  net_device     = "virtio-net"

  cpus   = var.cpus
  memory = var.memory_mb

  communicator           = "ssh"
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "60m"
  ssh_handshake_attempts = 100

  http_directory = "${var.project_dir}/http"
  boot_wait      = "10s"

  # This boot sequence is installer-family-specific. Replace it when adapting
  # the bundle to a distro that does not use Ubuntu/Subiquity autoinstall.
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  headless         = true
  vnc_bind_address = "127.0.0.1"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
}

source "qemu" "stage_51" {
  vm_name          = local.image_51_name
  output_directory = local.stage_51_output

  # build-images.sh creates this independent seed from immutable image -50.
  iso_url      = local.image_51_seed
  iso_checksum = "none"
  disk_image   = true

  accelerator    = "kvm"
  qemu_binary    = "qemu-system-x86_64"
  format         = "qcow2"
  disk_size      = var.disk_size
  disk_interface = "virtio"
  net_device     = "virtio-net"

  cpus   = var.cpus
  memory = var.memory_mb

  communicator           = "ssh"
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "30m"
  ssh_handshake_attempts = 100

  headless         = true
  vnc_bind_address = "127.0.0.1"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
}

build {
  name    = "stage-50"
  sources = ["source.qemu.stage_50"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${var.project_dir}/scripts/01-minimal-50.sh"
  }

  post-processor "shell-local" {
    inline = [
      "mkdir -p '${var.artifact_dir}'",
      "rm -f '${local.image_50_path}'",
      "mv '${local.stage_50_output}/${local.image_50_name}' '${local.image_50_path}'",
      "qemu-img check '${local.image_50_path}'",
      "qemu-img info '${local.image_50_path}'"
    ]
  }
}

build {
  name    = "stage-51"
  sources = ["source.qemu.stage_51"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${var.project_dir}/scripts/02-coin-configuration-51.sh"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${var.project_dir}/scripts/03-gnome-configuration-51.sh"
  }

  provisioner "shell" {
  execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
  script          = "${var.project_dir}/scripts/04-no-overview-extension-51.sh"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "${var.project_dir}/scripts/05-check-configurations-51.sh"
  }

  post-processor "shell-local" {
    inline = [
      "mkdir -p '${var.artifact_dir}'",
      "rm -f '${local.image_51_path}'",
      "mv '${local.stage_51_output}/${local.image_51_name}' '${local.image_51_path}'",
      "qemu-img check '${local.image_51_path}'",
      "qemu-img info '${local.image_51_path}'"
    ]
  }
}
