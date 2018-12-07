#storing resources that we want to create
#resource group
resource "azurerm_resource_group" "rg" {
        name = "myResourceGroup"
        location = "westeurope"

    tags {
        environment = "Terraform Demo"
    }
}

#virual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    tags {
        environment = "Terraform Demo"
    }
}
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.2.0/24"
}

#public IP adress allows us to acess resources across the internet
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "westeurope"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

#no network security

#A virtual network interface card (NIC) connects your VM to a given virtual network,
#public IP address, and network security group.
resource "azurerm_network_interface" "myterraformnic" {
    name                = "myNIC"
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    #network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#no storage account for diagnostics

#virtual machine - ubuntu
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "westeurope"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "akecan"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/akecan/.ssh/authorized_keys"
            #key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0VQV5p+f0kIMv/0HsJTspEldpCfWuaA+/gdR4b22d0KyKb5uVwkIkAaCRK8M/zFbP+zabFMLHuqs2uJWoWBhBLhNulU2RnTpjlUlz2Q9eadSbUi/rrFl3lJzftuF3icDNsIJwlIgK18t+LRGEmkwhXQonPfNfDQnOuQQuyEKVmmR2G7i9jYTNBFWf100WRahz0Gkn+SnAqMT0WHlXgHgmmvo4fy53EX3juPYiD/5gCP6CHcv9GBhAd267J8AK3HSO4MVndbKPMVYyOFzWlMujHDBhc81FIfVkimEwj3BERnNUZVc6b4ojmQXJEwmTRpoK7uSUEm5qRjrT+pseAXAx andreja@Andreja"
        }
    }

    #boot_diagnostics {
    #    enabled     = "true"
    #    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    #}

    tags {
        environment = "Terraform Demo"
    }
}

#vm extension for docker - deprecated (got stuck here)
resource "azurerm_virtual_machine_extension" "mydockerextension" {
    name = "DockerExtension"
    location = "westeurope"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
    publisher = "Microsoft.Azure.Extensions"
    type="DockerExtension"
    type_handler_version = "1.0"

    //type="CustomScript"
    //type_handler_version = "2.0"

   /* settings = <<SETTINGS
    {
        "fileUris": [""],       //url for script to be downloaded-git repo
        "commandToExecute": "hostname && uptime"   //komanda da se izvrsi skripta
    }
SETTINGS*/

    tags {
        environment = "Terraform Demo"
    }
}