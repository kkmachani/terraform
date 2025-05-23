data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = var.vm_public_ip
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  allocation_method   = "Static"

  tags = {
    environment = var.vm_tag
  }

  lifecycle {
    ignore_changes = [ name, tags ]
  }

}

resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  lifecycle {
    ignore_changes = [ name ]
  }
}

resource "azurerm_network_interface_security_group_association" "nsgnic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.nsg_id

  lifecycle {
    ignore_changes = [  network_interface_id, network_security_group_id  ]
  }
}


resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = data.azurerm_resource_group.existing_rg.location
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = var.osdisk
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.vm_tag
  }
  
  lifecycle {
    ignore_changes = [ vm.name, storage_os_disk.name, tags.environment ]
  }



  # Step 1: Copy local file to temporary location on VM
  provisioner "file" {
    source      = var.local_file_path
    destination = "/tmp/${basename(var.local_file_path)}"
    
    connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.vm_public_ip.ip_address
    }
  }


  # Step 2: Create directory and move file into it
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.remote_directory}",
      "mv /tmp/${basename(var.local_file_path)} ${var.remote_directory}/"
    ]

    connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.vm_public_ip.ip_address
    }
  }
}


