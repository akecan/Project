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

#A virtual network interface card (NIC) connects your VM to a given virtual network
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
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNlhrWRlU4nVUgETDAoq2X9pRjOPQ5YjV4J6io+vOXfESpyGQjTh+13DwaFxf2Nyjtl6E9vWn80284bxKMZS5j18YrTHbcBSWFz9/m8v4i/Ofyn1GojVCEf3RulKk25S8Jd74Sjsn/5VVd97LC86kchzBp9sixdipnGVBCQavvl18ap1eHwUNdFzyPA7ohmnGVnVtoxTiuA6bAJ5leQHPXTK1tJRTxsH4oNRb9fVHN5Dr/T6t663l19qfU/Qox6XPLbEFuOQMva6wefqe4JBBoKAQRx6WSIfmzrTUpEpBQnOw0z2+8iQG3gatrM4RfxKFppj/MmtbfjIzRM2AhCF+R"//andreja@Andreja
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

#vm extension for docker
resource "azurerm_virtual_machine_extension" "mydockerextension" {
    name = "DockerExtension"
    location = "westeurope"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
    publisher = "Microsoft.Azure.Extensions"
    type="DockerExtension"
    type_handler_version = "1.0"
    auto_upgrade_minor_version = true

    //type="CustomScript"
    //type_handler_version = "2.0"

    //"fileUris": ["/home/andreja/Desktop/hello.sh"],
    //url for script to be downloaded-git repo
    //command to execute script
    settings = <<SETTINGS
    {
        
        "commandToExecute": "sudo dockerd"
    }
SETTINGS

    tags {
        environment = "Terraform Demo"
    }
}
