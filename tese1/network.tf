# __      ___      _               _   _   _      _                      _    
# \ \    / (_)    | |             | | | \ | |    | |                    | |   
#  \ \  / / _ _ __| |_ _   _  __ _| | |  \| | ___| |___      _____  _ __| | __
#   \ \/ / | | '__| __| | | |/ _` | | | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /
#    \  /  | | |  | |_| |_| | (_| | | | |\  |  __/ |_ \ V  V / (_) | |  |   < 
#     \/   |_|_|   \__|\__,_|\__,_|_| |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\
#                                                                             
#                                                                             
# Section: Virtual Network
# ------------------------
# A Virtual Network (VNet) in Azure is a logical isolation of the Azure cloud dedicated to your resources. 
# It functions similarly to a traditional network you’d operate in your own data center, but with Azure-managed infrastructure.
resource "azurerm_virtual_network" "rg1" {
  name                = "vnet-intership-tese1"
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

#   _____       _                _       
#  / ____|     | |              | |      
# | (___  _   _| |__  _ __   ___| |_ ___ 
#  \___ \| | | | '_ \| '_ \ / _ \ __/ __|
#  ____) | |_| | |_) | | | |  __/ |_\__ \
# |_____/ \__,_|_.__/|_| |_|\___|\__|___/
#                                        
#                                        
# Section: Subnet 
# --------------
# A subnet is a subdivision of a Virtual Network (VNet) in Azure. It allows you to:
# Segment the IP address space of a VNet
# Organize resources logically
# Apply security rules and route tables at a finer level
# Deploy Azure services with subnet-specific configurations (e.g., Azure Bastion, NAT Gateway)

resource "azurerm_subnet" "virtual_machines" {
  name                 = "snet-virtual-machine"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.rg1.name
  address_prefixes     = ["192.168.1.32/27"]
}

resource "azurerm_subnet" "azurebastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.rg1.name
  address_prefixes     = ["192.168.1.224/27"]
}

#  _____       _     _ _        _____ _____     
# |  __ \     | |   | (_)      |_   _|  __ \    
# | |__) |   _| |__ | |_  ___    | | | |__) |__ 
# |  ___/ | | | '_ \| | |/ __|   | | |  ___/ __|
# | |   | |_| | |_) | | | (__   _| |_| |   \__ \
# |_|    \__,_|_.__/|_|_|\___| |_____|_|   |___/
#                                               
#                                               
#Section: Public IPs
#-------------------
# An Azure Public IP address is a globally unique IP address used to communicate with resources over the Internet.
# It enables inbound or outbound connectivity to/from Azure resources

resource "azurerm_public_ip" "bastion" {
  name                = "pip-tese1-bastion"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

resource "azurerm_public_ip" "natgw" {
  name                = "pip-tese1-natgw"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

#  ____            _   _             
# |  _ \          | | (_)            
# | |_) | __ _ ___| |_ _  ___  _ __  
# |  _ < / _` / __| __| |/ _ \| '_ \ 
# | |_) | (_| \__ \ |_| | (_) | | | |
# |____/ \__,_|___/\__|_|\___/|_| |_|
#                                    
#                                    
#Section: Azure Bastion
#----------------------
# Azure Bastion is a fully managed Platform-as-a-Service (PaaS) that provides secure and seamless RDP and SSH connectivity to virtual machines directly through the Azure portal, without exposing public IP addresses.

resource "azurerm_bastion_host" "bastion" {
  name                = "bst-intership-tese1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                 = "ipconfig"
    public_ip_address_id = azurerm_public_ip.bastion.id
    subnet_id            = azurerm_subnet.azurebastionsubnet.id
  }
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

#  _   _       _______    _____       _                           
# | \ | |   /\|__   __|  / ____|     | |                          
# |  \| |  /  \  | |    | |  __  __ _| |_ _____      ____ _ _   _ 
# | . ` | / /\ \ | |    | | |_ |/ _` | __/ _ \ \ /\ / / _` | | | |
# | |\  |/ ____ \| |    | |__| | (_| | ||  __/\ V  V / (_| | |_| |
# |_| \_/_/    \_\_|     \_____|\__,_|\__\___| \_/\_/ \__,_|\__, |
#                                                            __/ |
#                                                           |___/ 
#Section: Network Address Translation (NAT) Gateway
#--------------------------------------------------
# An Azure NAT Gateway is a highly scalable, outbound-only internet connectivity service for resources in an Azure Virtual Network (VNet). 
# It allows private virtual machines (VMs) or other compute resources without public IP addresses to initiate outbound connections to the internet using a static public IP or IP prefix, without exposing them to inbound traffic.

resource "azurerm_nat_gateway" "natgw" {
  name                    = "ng-internship-tese1"
  resource_group_name     = azurerm_resource_group.rg1.name
  location                = azurerm_resource_group.rg1.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = "4"
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

# After both the NAT GW and a dedicated Public IP been created, we need to associate them
resource "azurerm_nat_gateway_public_ip_association" "natgw" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

# Associate NAT Gateway with the subnet
resource "azurerm_subnet_nat_gateway_association" "natg" {
  nat_gateway_id = azurerm_nat_gateway.natgw.id
  subnet_id = azurerm_subnet.virtual_machines.id
  
}
#  _   _      _                      _       _____                      _ _            _____                       
# | \ | |    | |                    | |     / ____|                    (_) |          / ____|                      
# |  \| | ___| |___      _____  _ __| | __ | (___   ___  ___ _   _ _ __ _| |_ _   _  | |  __ _ __ ___  _   _ _ __  
# | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /  \___ \ / _ \/ __| | | | '__| | __| | | | | | |_ | '__/ _ \| | | | '_ \ 
# | |\  |  __/ |_ \ V  V / (_) | |  |   <   ____) |  __/ (__| |_| | |  | | |_| |_| | | |__| | | | (_) | |_| | |_) |
# |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ |_____/ \___|\___|\__,_|_|  |_|\__|\__, |  \_____|_|  \___/ \__,_| .__/ 
#                                                                              __/ |                        | |    
#                                                                             |___/                         |_|    
#Section: Network Security Group (NSG)
#-------------------------------------
#A Network Security Group (NSG) is an Azure firewall-like service that controls network traffic inbound to and outbound from Azure resources.
#It works at the network interface (NIC) or subnet level and allows you to filter traffic based on rules.

resource "azurerm_network_security_group" "virtual_machines" {
  name                = "nsg-internship-tese1-virtual-machines"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

# After a NSG has been created, we will need to assign it to one or more subnets
resource "azurerm_subnet_network_security_group_association" "name" {
  network_security_group_id = azurerm_network_security_group.virtual_machines.id
  subnet_id                 = azurerm_subnet.virtual_machines.id
}

#  _   _  _____  _____   _____       _           
# | \ | |/ ____|/ ____| |  __ \     | |          
# |  \| | (___ | |  __  | |__) |   _| | ___  ___ 
# | . ` |\___ \| | |_ | |  _  / | | | |/ _ \/ __|
# | |\  |____) | |__| | | | \ \ |_| | |  __/\__ \
# |_| \_|_____/ \_____| |_|  \_\__,_|_|\___||___/
#                                                
#                                                
#Section: NSG Rules
#------------------
# NSG Rules define how network traffic is allowed or denied to flow into (inbound) or out of (outbound)

#Inbound Rules
resource "azurerm_network_security_rule" "allow_bastion_inbound_rdp_ssh" {
  name                        = "Allow-Bastion-Inbound-RDP-SSH"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "deny_vnet_inbound" {
  name                        = "Deny_VNET_Inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

#Outbound Rules
resource "azurerm_network_security_rule" "allow_kms_outbound" {
  name                         = "Allow-KMS-Outbound"
  priority                     = 200
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "1688"
  source_address_prefix        = "VirtualNetwork"
  destination_address_prefixes = ["23.102.135.246/32", "20.118.99.224/32", "40.83.235.53/32"]
  resource_group_name          = azurerm_resource_group.rg1.name
  network_security_group_name  = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "allow_tenable_outbound" {
  name                         = "Allow_Connectivity_to_cloud.tenable.com"
  priority                     = 201
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_ranges      = ["80", "443"]
  source_address_prefix        = "VirtualNetwork"
  destination_address_prefixes = ["35.182.14.64/26", "3.98.92.0/25", "13.59.252.0/25", "54.175.125.192/26", "34.201.223.128/25", "3.132.217.0/25", "18.116.198.0/24", "44.192.244.0/24", "54.219.188.128/26", "13.56.21.128/25", "34.223.64.0/25", "44.242.181.128/25", "3.101.175.0/25", "35.82.51.128/25", "35.86.126.0/24", "54.93.254.128/26", "18.194.95.64/26", "3.124.123.128/25", "3.67.7.128/25", "35.177.219.0/26", "3.9.159.128/25", "18.168.180.128/25", "18.168.224.128/25", "3.251.224.0/24", "54.255.254.0/26", "18.139.204.0/25", "13.213.79.0/24", "13.210.1.64/26", "3.106.118.128/25", "3.26.100.0/24", "13.115.104.128/25", "35.73.219.128/25", "3.108.37.0/24", "15.228.125.0/24", "3.32.43.0/27"]
  resource_group_name          = azurerm_resource_group.rg1.name
  network_security_group_name  = azurerm_network_security_group.virtual_machines.name
}


resource "azurerm_network_security_rule" "allow_trendmicro_outbound" {
  name                         = "Allow_Connectivity_to_Trend_Micro_AV"
  priority                     = 202
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_ranges      = ["80", "443"]
  source_address_prefix        = "VirtualNetwork"
  destination_address_prefixes = ["3.64.23.104", "18.197.219.181", "3.126.181.219", "104.127.179.242", "23.218.127.158", "23.4.225.105", "23.62.160.42", "44.233.140.104", "44.233.111.149", "3.69.154.126", "35.157.137.250", "3.127.14.173", "3.121.21.175", "18.193.243.182", "54.93.212.145", "3.123.240.99", "3.124.27.160", "18.197.235.39"]
  resource_group_name          = azurerm_resource_group.rg1.name
  network_security_group_name  = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "allow_azure_monitor_outbound" {
  name                        = "Allow_Connectivity_to_Azure_Monitor"
  priority                    = 203
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureMonitor"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "allow_azure_platform_outbound" {
  name                        = "Allow-Azure-Platform-Outbound"
  priority                    = 205
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "168.63.129.16"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "deny_virtual_network_outbound" {
  name                        = "Deny_Vnet_outbound"
  priority                    = 3999
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "deny_internet_outbound" {
  name                        = "Deny_Internet_outbound"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}