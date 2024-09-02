azure = {
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
resource_group = {
  name = "HznCloudAutoDeployTerraform"
  deployment_location = "australiaeast"
}
vnet = {
  name = "hzn_cloud_vnet",
  address_space = "192.168.252.0/22"
}
management_subnet = {
  name = "hzn_mgmt_subnet"
  address_prefix = "192.168.252.0/27"
}
dmz_subnet = {
  name = "hzn_dmz_subnet"
  address_prefix = "192.168.253.0/27"
}
desktop_subnet = {
  name = "hzn_desktop_subnet"
  address_prefix = "192.168.254.0/24"
}
dns_servers = [
  "1.1.1.1",
  "8.8.8.8",
  "168.63.129.16"
]
azure_public_ip = {
  prefix = "29"
  prefix_name = "hzn_cloud_pub_ip_prefix"
  ip_name = "hzn_cloud_pub_ip"
}
nat_gateway = {
  name = "hzn_cloud_nat_gateway"
}
aks_edge_cluster = {
  docker_bridge_cidr = "172.17.0.0/16"
  service_cidr = "192.168.251.0/27"
  pod_cidr = "192.168.240.0/21"
  nodes = "4"
}
identities = {
    service_principal_role_name = "Horizon Cloud Custom Service Principal Role"
    service_principal_role_description = "All permissions required for deployment and operation of a Horizon Edge in Azure."
    service_principal_name = "HznCloudServicePrincipal"
    compute_ro_role_name = "Horizon Cloud Azure Compute Read-Only Role"
    compute_ro_role_description = "Custom Read-Only Role for Microsoft Azure Compute Galleries."
    managed_identity_name = "HznCloudManagedIdentity"
}
service_principal_roles = ["Microsoft.Authorization/*/read","Microsoft.Compute/*/read","Microsoft.Compute/availabilitySets/*","Microsoft.Compute/disks/*","Microsoft.Compute/galleries/read","Microsoft.Compute/galleries/write","Microsoft.Compute/galleries/delete","Microsoft.Compute/galleries/images/*","Microsoft.Compute/galleries/images/versions/*","Microsoft.Compute/images/*","Microsoft.Compute/locations/*","Microsoft.Compute/snapshots/*","Microsoft.ContainerService/managedClusters/read","Microsoft.ContainerService/managedClusters/write","Microsoft.ContainerService/managedClusters/commandResults/read","Microsoft.ContainerService/managedClusters/runcommand/action","Microsoft.ContainerService/managedClusters/upgradeProfiles/read","Microsoft.ManagedIdentity/userAssignedIdentities/*/assign/action","Microsoft.ManagedIdentity/userAssignedIdentities/*/read","Microsoft.Compute/virtualMachines/*","Microsoft.Compute/virtualMachineScaleSets/*","Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/read","Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/write","Microsoft.Network/loadBalancers/*","Microsoft.Network/networkInterfaces/*","Microsoft.Network/networkSecurityGroups/*","Microsoft.Network/virtualNetworks/read","Microsoft.Network/virtualNetworks/write","Microsoft.Network/virtualNetworks/checkIpAddressAvailability/read","Microsoft.Network/virtualNetworks/subnets/*","Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read","Microsoft.ResourceGraph/*","Microsoft.Resources/deployments/*","Microsoft.Resources/subscriptions/read","Microsoft.Resources/subscriptions/resourceGroups/*","Microsoft.ResourceHealth/availabilityStatuses/read","Microsoft.Storage/*/read","Microsoft.Storage/storageAccounts/*","Microsoft.KeyVault/*/read","Microsoft.KeyVault/vaults/*","Microsoft.KeyVault/vaults/secrets/*","Microsoft.Network/natGateways/join/action","Microsoft.Network/natGateways/read","Microsoft.Network/privateEndpoints/write","Microsoft.Network/privateEndpoints/read","Microsoft.Network/publicIPAddresses/*","Microsoft.Network/routeTables/join/action","Microsoft.Network/routeTables/read"]
compute_read_only_roles = ["Microsoft.Compute/galleries/read"]
resource_providers = ["Microsoft.Authorization","Microsoft.Compute","Microsoft.ContainerService","Microsoft.KeyVault","Microsoft.MarketplaceOrdering","Microsoft.ResourceGraph","Microsoft.Network","Microsoft.Resources","Microsoft.Security","Microsoft.Storage","Microsoft.ManagedIdentity"]
horizon = {
  csp_api_key = ""
  csp_org_id = ""
}
active_directory = {
  name = "YOURCOMPANY"
  fqdn = "your.company.com"
  bind_primary_username = "bindadmpri"
  bind_primary_password = "password"
  bind_aux_username = "bindadminaux"
  bind_aux_password = "password"
  join_primary_username = "joinadminpro"
  join_primary_password = "password"
  join_aux_username = "joinadminaux"
  join_aux_password = "password"
  default_ou = "OU=Computers,DC=company,DC=local"
}
ca = {
  config_dn = "CN=Configuration,DC=company,DC=local"
  ca_mode = "root"
}
sites = {
  site_name = "HznCloudAutoDeploySite"
}
edges = {
  edge_name = "HznCloudAutoDeployEdge"
  enable_private_endpoint = "true"
  edge_fqdn = "edge.company.com"
}
uags = {
  cluster_min = "1"
  cluster_max = "2"
  uag_name = "HznCloudAutoDeployUAG"
  uag_fqdn = "uag.company.com"
  number_of_gateways = "2"
  type = "INTERNAL_AND_EXTERNAL"
}
ssl_certificate = {
  cert = ""
  password = ""
  type = "PEM"
}

