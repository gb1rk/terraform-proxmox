terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      # Version 3.0.1-rc6 is the latest version at the time of writing and this worked for me
      version = "3.0.1-rc6"
    }
  }
}
provider "proxmox" {
  # These are references in the variables file, vars.tf
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  # Insecure TLS connection, fixes x509: certificate signed by unknown authority issue
  # This is not best practice, but it is a workaround for internal- & insecure environments
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "test-clone" {
    name = "example.vm.name" # Name of the VM
    desc = "Test Proxmox API VM" # Description of the VM
    target_node = "pve" # Which host in your Proxmox Cluster
    clone = "example.template.name" # Name of the template to clone
    full_clone = "true" # Full clone, not linked clone
    cores = 1 # Number of CPU cores
    sockets = 1 # Number of CPU sockets
    memory = 512 # MB
    scsihw = "virtio-scsi-single" # virtio-scsi-single worked for me, but you can try other values like virtio-scsi-pci
    bootdisk = "ide0" # Boot disk, ide0 worked for me, but you can try other values like scsi0
    bios = "ovmf" # ovmf worked for me on Alma9, but you can try other values like seabios

# This is where it became a bit clunky for me, i had issues with the bootdisk not being mounted, so i had to specify
# the disk in this part, i dont know if this is ideal, but it worked for me
 disks {
    ide0 {
        ide0 {
            disk {
                size = "80G" # GB
                storage = "local-lvm" # Storage type, name this where the disk will be stored
            }
        }
    }
 }
}