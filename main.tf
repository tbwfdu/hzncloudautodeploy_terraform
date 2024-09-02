/*
Horizon Cloud NextGen Terraform deployment.

    Before running terraform apply you should login to Azure using the Azure Command Utils:

    # az login
    # az account set --subscription "Your Azure Subscription Name"
     
    Now, you can run: 
    # terraform plan -out HznCloud
    # terraform apply HznCloud
    
    To view the Service Principal Details:
    # terraform output service_principal_id
    # terraform output service_principal_password
*/

/*
Define the variables to be used.
Note: These will be overriden by anything entered into terraform.tfvars file.
*/

# Azure Infrastructure Specific Variables
variable "azure" {
    type = map(string)
    default = {
        subscription_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        tenant_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }
}
variable "resource_group" {
    type = map(string)
    default = {
        name: "HorizonCloudNextGen"
        deployment_location: "useast"
    }
}
variable "vnet" {
    type = map(string)
    default = {
        name: "hzn_cloud_vnet"
        address_space: "192.168.252.0/22"
    }
}
variable "management_subnet" {
    type = map(string)
    default = {
        name: "hzn_mgmt_subnet"
        address_prefix: "192.168.252.0/27"
    }
}
variable "dmz_subnet" {
    type = map(string)
    default = {
        name: "hzn_dmz_subnet"
        address_prefix: "192.168.253.0/27"
    }
}
variable "desktop_subnet" {
    type = map(string)
    default = {
        name: "hzn_desktop_subnet"
        address_prefix: "192.168.254.0/24"
    }
}
variable "dns_servers" {
    type = list(string)
    description = ""
    default     = ["1.1.1.1", "8.8.8.8", "168.63.129.16"]
}
variable "nat_gateway" {
    type = map(string)
    default = {
        name: "hzn_cloud_nat_gateway"
    }
}
variable "aks_edge_cluster" {
    type = map(string)
    default = {
        docker_bridge_cidr: "172.17.0.0/16"
        service_cidr: "192.168.251.0/27"
        pod_cidr: "192.168.240.0/21"
        nodes: "4"
    }
}
variable "azure_public_ip" {
    type = map(string)
    default = {
        prefix: "29"
        prefix_name: "hzn_cloud_pub_ip_prefix"
        ip_name: "hzn_cloud_pub_ip"
    }
}
variable "identities" {
    type = map(string)
    default = {
        service_principal_role_name: "Horizon Cloud Custom Service Principal Role"
        service_principal_role_description: "All permissions required for deployment and operation of a Horizon Edge in Azure."
        service_principal_name: "HznCloudServicePrincipal"
        compute_ro_role_name: "Horizon Cloud Azure Compute Read-Only Role"
        compute_ro_role_description: "Custom Read-Only Role for Microsoft Azure Compute Galleries."
        managed_identity_name: "HznCloudManagedIdentity"
    }
}
variable "service_principal_roles" {
    type = list(string)
    description = ""
    default     = []
}
variable "compute_read_only_roles" {
    type = list(string)
    description = ""
    default     = []
}
variable "resource_providers" {
    type = list(string)
    description = ""
    default     = []
}
# Horizon Cloud NextGen Specific Variables
variable "horizon" {
    type = map(string)
    default = {
        csp_api_key: ""
        csp_org_id: ""
    }
}
variable "active_directory" {
    type = map(string)
    default = {
        name: "YOURCOMPANY"
        fqdn: "your.company.com"
        bind_primary_username: "bindadmpri"
        bind_primary_password: "password"
        bind_aux_username: "bindadminaux"
        bind_aux_password: "password"
        join_primary_username: "joinadminpro"
        join_primary_password: "password"
        join_aux_username: "joinadminaux"
        join_aux_password: "password"
        default_ou: "OU=Computers,DC=company,DC=local"
    }
}
variable "ca" {
    type = map(string)
    default = {
        config_dn: "CN=Configuration,DC=company,DC=local"
        ca_mode: "root"
    }
}
variable "sites" {
    type = map(string)
    default = {
        site_name: "HznCloudAutoDeploySite"
    }
}
variable "edges" {
    type = map(string)
    default = {
        edge_name: "HznCloudAutoDeployEdge"
        enable_private_endpoint: "true"
        edge_fqdn: "edge.company.com"
    }
}
variable "uags" {
    type = map(string)
    default = {
        cluster_min: "1"
        cluster_max: "2"
        uag_name: "HznCloudAutoDeployUAG"
        uag_fqdn: "uag.company.com"
        number_of_gateways: "2"
        type: "INTERNAL_AND_EXTERNAL"
    }
}
variable "ssl_certificate" {
    type = map(string)
    default = {
        cert: ""
        password: ""
        type: "PEM"
    }
}

variable "skip_resource_providers" {
    type = bool
    default = true
}

# Configure the Azure Resource Manager Provider
terraform {
  required_providers { 
          azurerm = { 
              source  = "hashicorp/azurerm"
              version = "~> 3.0.2" 
          }
          azuread = {
              source  = "hashicorp/azuread"
              version = "~> 2.15.0"
          } 
      }
  required_version = ">= 1.1.0"
}
provider "azurerm" { 
    features { 
        resource_group { 
            prevent_deletion_if_contains_resources = false 
        } 
    }
    subscription_id         = var.azure.subscription_id
    tenant_id               = var.azure.tenant_id
    skip_provider_registration = true
}

provider "azuread" {}

# Create a new Resource Group
resource "azurerm_resource_group" "hzncloud_autodeploy_terraform" {
    name                    = var.resource_group.name
    location                = var.resource_group.deployment_location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "hzncloud_vnet" {
    name                    = var.vnet.name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    address_space           = [var.vnet.address_space]
    dns_servers             = var.dns_servers
}

# Create the Management Subnet
resource "azurerm_subnet" "management_subnet" {
    name                 = var.management_subnet.name
    resource_group_name  = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    virtual_network_name = azurerm_virtual_network.hzncloud_vnet.name
    address_prefixes     = [var.management_subnet.address_prefix]
}

# Create the DMZ Subnet
resource "azurerm_subnet" "dmz_subnet" {
    name                 = var.dmz_subnet.name
    resource_group_name  = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    virtual_network_name = azurerm_virtual_network.hzncloud_vnet.name
    address_prefixes     = [var.dmz_subnet.address_prefix]
}

# Create the Desktop Subnet
resource "azurerm_subnet" "desktop_subnet" {
    name                 = var.desktop_subnet.name
    resource_group_name  = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    virtual_network_name = azurerm_virtual_network.hzncloud_vnet.name
    address_prefixes     = [var.desktop_subnet.address_prefix]
}

# Create a Public IP CIDR Reservation
resource "azurerm_public_ip_prefix" "new_public_ip_prefix" {
    name                    = var.azure_public_ip.prefix_name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    prefix_length           = var.azure_public_ip.prefix
    zones                   = ["1"]
}

# Create a Public IP based on the Public IP Prefix
resource "azurerm_public_ip" "new_public_ip" {
    name                    = var.azure_public_ip.ip_name
    resource_group_name     = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    location                = var.resource_group.deployment_location
    allocation_method       = "Static"
    public_ip_prefix_id     = azurerm_public_ip_prefix.new_public_ip_prefix.id
    sku                     = "Standard"
}

# Create a NAT Gateway
resource "azurerm_nat_gateway" "new_nat_gateway" {
    name                    = var.nat_gateway.name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.hzncloud_autodeploy_terraform.name
    sku_name                = "Standard"
}

# Associate a Public IP to the NAT Gateway from the reserved CIDR block
resource "azurerm_nat_gateway_public_ip_association" "new_public_ip_association" { 
    nat_gateway_id          = azurerm_nat_gateway.new_nat_gateway.id
    public_ip_address_id    = azurerm_public_ip.new_public_ip.id
}

# Associate the Management Subnet to the NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "mgmt_subnet_nat_gateway_association" {
    subnet_id               = azurerm_subnet.management_subnet.id
    nat_gateway_id          = azurerm_nat_gateway.new_nat_gateway.id
}

# Ensure that all Resource Providers are enabled
resource "azurerm_resource_provider_registration" "new_provider_registration" {
    for_each = var.skip_resource_providers ? toset([]) : toset( var.resource_providers )
    name = each.key
}

# Create Custom Service Principal Role
resource "azurerm_role_definition" "new_service_principal_role" {
    name                    = var.identities.service_principal_role_name
    description             = var.identities.service_principal_role_description
    scope                   = "/subscriptions/${var.azure.subscription_id}"
    permissions {
        actions             = var.service_principal_roles
        not_actions         = []
    }
    //assignable_scopes       = ["/subscriptions/${var.azure.subscription_id}", "/subscriptions/resourceGroups/${azurerm_resource_group.hzncloud_autodeploy_terraform.name}"]
}

# Create Custom Compute Gallery Read-Only Role
resource "azurerm_role_definition" "new_compute_read_only_role" {
    name                    = var.identities.compute_ro_role_name
    description             = var.identities.compute_ro_role_description
    scope                   = "/subscriptions/${var.azure.subscription_id}"
    permissions {
        actions             = var.compute_read_only_roles
        not_actions         = []
    }
    //assignable_scopes       = ["/subscriptions/${var.azure.subscription_id}", "/subscriptions/resourceGroups/${azurerm_resource_group.hzncloud_autodeploy_terraform.name}"]
}

# Create Managed Identity
resource "azurerm_user_assigned_identity" "new_managed_identity" {
    name                    = var.identities.managed_identity_name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.hzncloud_autodeploy_terraform.name
}
# Assign the Managed Identity Roles
resource "azurerm_role_assignment" "assign_identity_network_contributor" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = "Network Contributor"
    principal_id         = azurerm_user_assigned_identity.new_managed_identity.principal_id
}
resource "azurerm_role_assignment" "assign_identity_managed_identity_operator" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = "Managed Identity Operator"
    principal_id         = azurerm_user_assigned_identity.new_managed_identity.principal_id
}

output "managed_identity_client_id" {
    value = azurerm_user_assigned_identity.new_managed_identity.client_id
}

# Create Enterprise Application
data "azuread_client_config" "current" {}

resource "azuread_application" "new_application" {
    display_name            = "HznCloud"
    owners           = [data.azuread_client_config.current.object_id]
}

# Create Service Principal
resource "azuread_service_principal" "new_service_principal" {
    application_id          = azuread_application.new_application.application_id
    app_role_assignment_required = false
}

# Assign the Service Principal Roles
resource "azurerm_role_assignment" "assign_new_service_principal_role" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = azurerm_role_definition.new_service_principal_role.name
    principal_id         = azuread_service_principal.new_service_principal.id
}
resource "azurerm_role_assignment" "assign_new_compute_read_only_role" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = azurerm_role_definition.new_compute_read_only_role.name
    principal_id         = azuread_service_principal.new_service_principal.id
}

# Create Service Principal Password
resource "azuread_service_principal_password" "service_principal_app_password" {
    service_principal_id = azuread_service_principal.new_service_principal.id
}

# Output the Service Principal and Password
output "service_principal_id" {
    value     = azuread_service_principal.new_service_principal.id
    sensitive = true
}

output "service_principal_password" {
    value     = azuread_service_principal_password.service_principal_app_password.value
    sensitive = true
}