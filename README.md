# HznCloudAutodeploy - Terraform
Deploy Omnissa Horizon Cloud using Terraform

# Instructions:
    
#### ❗ Ensure you have the Azure Command Line Tools installed for your OS. ❗
    
#### ❗Ensure you have Terraform installed for your OS. ❗

1. In the main directory of this repo after you have cloned it, edit the `terraform.tfvars` file and adjust the variables to suit your environment.

2. Log in to your Azure Environment using `az login`

3. Set your session to the Azure Subscription where you want to create the Horizon Cloud Deployment using `az account set --subscription "Your Azure Subscription Name"`

4. On the very first run, you need to get the Terraform Providers. Run `terraform init`.

5. Test your config using `terraform validate`.

6. Now you will able deploy against your settings:

    `terraform plan -out HznCloud`

    `terraform apply HznCloud`
<br>

#### ℹ️ If at any point you need to view the Service Principal Details:

`terraform output service_principal_id`

`terraform output service_principal_password`

<br>

# Configuration Information

**_The Application Will:_**

**In Azure:**

- Create a Single Resouce Group in your Azure subscription.
- Create a VNet in this Resource Group.
- Creates three (3) Subnets in this VNet:
- Management Subnet
- DMZ Subnet
- Desktop Subnet
- Create a Public IP Prefix (reservation)
- Create a Public IP for a NAT Gateway
- Create a NAT Gateway
- Assign the NAT Gateway to the Management Subnet
- Assigns the DNS Server settings to the VNet.
- Creates two (2) Custom Roles:
  - Service Principal Role with minimum capabilities needed for the Service Principal used by Horizon Cloud.
  - Azure Compute Read-Only role with permissions on to Read on Azure Compute Resources.
- Creates a User Managed Identity
- Assigns the Managed Identity the Network Contributor & Managed Identity Operator built-in roles.
- Creates an Enterprise Application.
- Creates a Service Principal, ClientID and Client Secret for the Enterprise Application.

**In Horizon Cloud:**

- Add an Active Directory Configuration
- Create a SSO Configuration for your Domain
- Create a Site
- Create an Azure Provider for your Azure Subscription
- Deploy an Edge Cluster using Azure AKS, to your Azure Subscription
- Create a Site to Edge Mapping
- Deploy a UAG Cluster to your Azure Subscription


## Azure Configuration in tfvars

**Subscription ID** - The ID of the Subscription in Azure you want to deploy against.
```
subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```
**Tenant ID** - The Tenant ID in Azure
```
tenant_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Resource Group

**Name** - The name of the Resource Group that will be created in Azure.
```
name = "HznCloudAutoDeploy" (can be adjusted)
```

**Azure Region** - Where you want to create the Resource Group and deploy all Horizon Components.
```
deployment_location = "australiaeast" (can be adjusted)
```

### Networking

**VNets and Subnets** - Details of the VNet and Subnets required
```
management_subnet = "192.168.252.0/27" - Management (Edge) VNet Range
(can be adjusted, minimum of /27, must not conflict refer to documentation)
```
```
dmz_subnet = "192.168.253.0/27" - DMZ VNet (UAG) Range
(can be adjusted, minimum of /27, must not conflict refer to documentation)
```
```
desktop_subnet = "192.168.254.0/24"  - Desktop (VM) Range
(can be adjusted, must not conflict refer to documentation)
```
**Customer Domain DNS Server Address & External DNS** - Should be internal DNS for internal resource resolution, plus added external for external resolution
```
dns_servers:
  -8.8.8.8
  -1.1.1.1
  -168.63.129.16 <-- this MUST remain as it is used for Azure Internal Routing
```

### Docker, Service and Pod CIDR
Used for Edge Cluster AKS deployment, these will be in their own Resource Group (and a new VNet will be created for these subnets).

### Roles & Account Names

Name of the custom role to be created in place of Contributor for Horizon Cloud Service Principals
```
service_principal_role_name = "Horizon Cloud Custom Service Principal Role" (can be adjusted)
```
Service Principal Name to be created
```
service_principal_name = "HznCloudServicePrincipal" (can be adjusted)
```
Name of the custom role to be created for Azure Compute ReadOnly
```
compute_ro_role_name = "Horizon Cloud Azure Compute Read-Only Role" (can be adjusted)
```
Managed User Identity Name to be created
```
managed_identity_name = "HznCloudManagedIdentity" (can be adjusted)
```


## Horizon Configuration in tfvars

### CSP API Key

In your Cloud Services Portal, under your User Account, go to API Keys and generate an API Key.

## CSP API Key 

In your Cloud Services Portal, copy your Organization ID (long version) by clicking your name in the top right corner, and it will appear at the top of the menu.

## Active Directory

Name is a "friendly name" to reference your dir by.

FQDN is your directory's internal dns name (eg. company.local or company.com etc.)

Bind & Join Primary and Auxilliary accounts. These are used for connecting to AD and Joining VMs to AD. Refer to documentation for more information.