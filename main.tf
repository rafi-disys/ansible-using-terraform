resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rafi-rg.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rafi-rg.location
  resource_group_name      = azurerm_resource_group.rafi-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Resource 5: With custom data 
resource "azurerm_linux_virtual_machine" "ansible_vm" {
  name                            = "ansible-vm"
  location                        = azurerm_resource_group.rafi-rg.location
  resource_group_name             = azurerm_resource_group.rafi-rg.name
  size                            = "Standard_B1s"
  
  network_interface_ids = [azurerm_network_interface.ansible.id]

  admin_username                  = "adminuser"
  admin_password = "Terraform@123"
  disable_password_authentication = true

  admin_ssh_key {
    username =  "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  } 

  custom_data = base64encode(data.template_file.ansible_install.rendered)

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

data "template_file" "ansible_install" {
  template = file("ansible_install.sh")
}



# resource "azurerm_virtual_machine" "vm" {
#   name                  = "centos-vm"
#   location              = azurerm_resource_group.rg.location
#   resource_group_name   = azurerm_resource_group.rg.name
#   network_interface_ids = [azurerm_network_interface.nic.id]
#   vm_size               = "Standard_B1s"

#   storage_image_reference {
#     publisher = "OpenLogic"
#     offer     = "CentOS"
#     sku       = "7_9"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name              = "${azurerm_virtual_machine.vm.name}-osdisk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   os_profile {
#     computer_name  = "${azurerm_virtual_machine.vm.name}-computername"
#     admin_username = "<admin_username>"
#     admin_password = "<admin_password>"
#   }

# provisioner "remote-exec" {
#     inline=[
#       # Install Ansible
#       'sudo yum update -y',
#       'sudo yum install -y epel-release',
#       'sudo yum install -y ansible',
#       # Verify Ansible installation
#       'ansible --version'
#     ]
# }
# }



#Resource- 5: Linux VM with local provisioner
# resource "azurerm_linux_virtual_machine" "ansible" {
#   name                = "ansible-vm"
#   location            = azurerm_resource_group.rafi-rg.location
#   resource_group_name = azurerm_resource_group.rafi-rg.name

#   size           = "Standard_B1ms"
#   admin_username = "adminuser"

#   admin_ssh_key {
#     username   = "adminuser"
#     #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7WsDhzW8uHy7QJX9rn09l7OGntuwW8LjzCYwFhKm7Y1zhWkG8PKVx2tsiHP70vZgyMnmZ/D8i6ommpG6u5YV82kW6u8hV1i9/udE7B0/40fuU8SdSJeRnR/KoyYiYjK68y3q4rqH4aMfMN2QLEiwgjI2tQsOz+FvevAIKbIPyDrhdFTfZY9XzbfKjC1elTcnTzGGhSezdDuywW/Hn8/yYktr9h9cQaH/wWZu8gAlIUGe6uH7rU3k6/P8QVdcFL9RITG7VjxZNLg8ZuD33oif/Ik0Uh1OaO/fRH8tdYKj9XGwn4q3qW1OgjKmsZs1zLkQsIhjyCynvNph9X ansible-generated-key"
#   }

#   source_image_reference {
#     publisher = "OpenLogic"
#     offer     = "CentOS"
#     sku       = "7.9"
#     version   = "latest"
#   }

#   network_interface_ids = [azurerm_network_interface.ansible.id]

#   os_disk {
#     name                 = "my-os-disk"
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   boot_diagnostics {
#     storage_account_uri = "YOUR_STORAGE_ACCOUNT_URI_HERE"
#   }

#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       host        = azurerm_linux_virtual_machine.ansible.public_ip_address
#       user        = "adminuser"
#       private_key = file("~/.ssh/id_rsa")
#     }

#     inline = [
#       "sudo yum -y install epel-release",
#       "sudo yum -y install ansible"
#     ]
#   }
# }
