#  _____                                       _____                       
# |  __ \                                     / ____|                      
# | |__) |___  ___  ___  _   _ _ __ ___ ___  | |  __ _ __ ___  _   _ _ __  
# |  _  // _ \/ __|/ _ \| | | | '__/ __/ _ \ | | |_ | '__/ _ \| | | | '_ \ 
# | | \ \  __/\__ \ (_) | |_| | | | (_|  __/ | |__| | | | (_) | |_| | |_) |
# |_|  \_\___||___/\___/ \__,_|_|  \___\___|  \_____|_|  \___/ \__,_| .__/ 
#                                                                   | |    
#                                                                   |_|    
#Section: Resource Group
#-----------------------
# An Azure Resource Group is a logical container that holds related Azure resources such as virtual machines, networks, databases, and storage accounts. 
# It acts as a unit of management for deployment, monitoring, access control, and lifecycle.

resource "azurerm_resource_group" "rg1" {
  name     = "rg-internship-tese1"
  location = "West Europe"
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}


#  _  __           __      __         _ _   
# | |/ /           \ \    / /        | | |  
# | ' / ___ _   _   \ \  / /_ _ _   _| | |_ 
# |  < / _ \ | | |   \ \/ / _` | | | | | __|
# | . \  __/ |_| |    \  / (_| | |_| | | |_ 
# |_|\_\___|\__, |     \/ \__,_|\__,_|_|\__|
#            __/ |                          
#           |___/                           
#Section: Azure Key Vault
#-------------------------
# Azure Key Vault is a cloud-based service from Microsoft Azure that helps you securely store and manage sensitive information.
resource "azurerm_key_vault" "tese1" {
  name                      = "kv-internship-tese1"
  resource_group_name       = azurerm_resource_group.rg1.name
  location                  = azurerm_resource_group.rg1.location
  sku_name                  = "standard"
  enable_rbac_authorization = true
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}


#   _____  ____  _         _____                          
#  / ____|/ __ \| |       / ____|                         
# | (___ | |  | | |      | (___   ___ _ ____   _____ _ __ 
#  \___ \| |  | | |       \___ \ / _ \ '__\ \ / / _ \ '__|
#  ____) | |__| | |____   ____) |  __/ |   \ V /  __/ |   
# |_____/ \___\_\______| |_____/ \___|_|    \_/ \___|_|   
#                                                         
#                                                         
#
#Section: SQL Server
#-------------------
#An Azure SQL Server is a logical container or management boundary in Microsoft Azure for managing Azure SQL Databases and Azure SQL Managed Instances.
#It’s a platform-as-a-service (PaaS) wrapper used to group and secure Azure SQL databases.

# Generate a random password for SQL
resource "random_password" "sql" {
  length           = 24
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

# Store VM password in a Key Vault
resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sqladmin-password"
  value        = random_password.sql.result
  key_vault_id = azurerm_key_vault.tese1.id
  content_type = "password"
}

# Finally, create the SQL Server
resource "azurerm_mssql_server" "tese1" {
  name                         = "sql-internship-tese1"
  resource_group_name          = azurerm_resource_group.rg1.name
  location                     = azurerm_resource_group.rg1.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql.result

  identity {
    type = "SystemAssigned"
  }
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

#   _____  ____  _        _____        _        _                    
#  / ____|/ __ \| |      |  __ \      | |      | |                   
# | (___ | |  | | |      | |  | | __ _| |_ __ _| |__   __ _ ___  ___ 
#  \___ \| |  | | |      | |  | |/ _` | __/ _` | '_ \ / _` / __|/ _ \
#  ____) | |__| | |____  | |__| | (_| | || (_| | |_) | (_| \__ \  __/
# |_____/ \___\_\______| |_____/ \__,_|\__\__,_|_.__/ \__,_|___/\___|
#                                                                    
#Section: SQL Database
#---------------------
#Azure SQL Database is a fully managed relational database service built on Microsoft SQL Server technology, offered as a Platform as a Service (PaaS). 
#It provides the full functionality of SQL Server without needing to manage infrastructure, updates, backups, or high availability.                                                             

resource "azurerm_mssql_database" "tese1" {
  name               = "sqldb-tese1"
  server_id          = azurerm_mssql_server.tese1.id
  sku_name           = "S0"
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb        = 5
  zone_redundant     = false
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

#  _   _      _                      _      _____       _             __                  _____              _ 
# | \ | |    | |                    | |    |_   _|     | |           / _|                / ____|            | |
# |  \| | ___| |___      _____  _ __| | __   | |  _ __ | |_ ___ _ __| |_ __ _  ___ ___  | |     __ _ _ __ __| |
# | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /   | | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \ | |    / _` | '__/ _` |
# | |\  |  __/ |_ \ V  V / (_) | |  |   <   _| |_| | | | ||  __/ |  | || (_| | (_|  __/ | |___| (_| | | | (_| |
# |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ |_____|_| |_|\__\___|_|  |_| \__,_|\___\___|  \_____\__,_|_|  \__,_|
#                                                                                                              
#                                                                                                              
#Section: Network Interface Card
#-------------------------------
#A NIC (Network Interface Card) in Azure — also called a network interface resource — is the virtual networking component that connects a virtual machine (VM) to an Azure Virtual Network (VNet).
resource "azurerm_network_interface" "vm1" {
  name                = "nic-vm-tese1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.virtual_machines.id
  }
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}

# __      ___      _               _   __  __            _     _            
# \ \    / (_)    | |             | | |  \/  |          | |   (_)           
#  \ \  / / _ _ __| |_ _   _  __ _| | | \  / | __ _  ___| |__  _ _ __   ___ 
#   \ \/ / | | '__| __| | | |/ _` | | | |\/| |/ _` |/ __| '_ \| | '_ \ / _ \
#    \  /  | | |  | |_| |_| | (_| | | | |  | | (_| | (__| | | | | | | |  __/
#     \/   |_|_|   \__|\__,_|\__,_|_| |_|  |_|\__,_|\___|_| |_|_|_| |_|\___|
#                                                                           
#                                                                           
#Section: Virtual Machine
#------------------------
#An Azure Virtual Machine (VM) is an on-demand, scalable computing resource provided by Microsoft Azure. 
#It lets you run Windows or Linux operating systems in the cloud, similar to how you'd run them on a physical server — but without having to buy or maintain hardware.

# Generate Random password for VMs
resource "random_password" "vm" {
  length           = 24
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

resource "azurerm_key_vault_secret" "vm_admin" {
  name         = "vm-admin"
  value        = "Internship-Admin"
  key_vault_id = azurerm_key_vault.tese1.id
  content_type = "Username"
}

# Store VM password in a Key Vault
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-password"
  value        = random_password.vm.result
  key_vault_id = azurerm_key_vault.tese1.id
  content_type = "password"
}

# Create the Virtual Machine
resource "azurerm_windows_virtual_machine" "vm1" {
  name                     = "vm-tese1"
  resource_group_name      = azurerm_resource_group.rg1.name
  location                 = azurerm_resource_group.rg1.location
  size                     = "Standard_D2s_v5"
  admin_username           = azurerm_key_vault_secret.vm_admin.value
  admin_password           = random_password.vm.result
  enable_automatic_updates = false
  patch_mode               = "Manual"

  network_interface_ids = [
    azurerm_network_interface.vm1.id
  ]
  os_disk {
    name                 = "dsk-vm-tese1-osdisk"
    disk_size_gb         = "127"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
  tags = merge(local.tags, {
    "cvt_lcm_create_date" = "20250529"
  })
}