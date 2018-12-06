#identifies how you are going to authenticate to azure resource manager api (or other cloud service)
provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}
