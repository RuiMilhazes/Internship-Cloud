#  ____             _                  _ 
# |  _ \           | |                | |
# | |_) | __ _  ___| | _____ _ __   __| |
# |  _ < / _` |/ __| |/ / _ \ '_ \ / _` |
# | |_) | (_| | (__|   <  __/ | | | (_| |
# |____/ \__,_|\___|_|\_\___|_| |_|\__,_|
#                                        
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-iac-statefile"
    storage_account_name = "stintrnshpiacstate"
    container_name       = "iac-tese1"
    key                  = "terraform.tfstate"
    subscription_id      = "0cf2fa8e-27a5-4721-9801-2fa98f8b8c3e"
  }
}