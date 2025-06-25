# __      __           _                 
# \ \    / /          (_)                
#  \ \  / /__ _ __ ___ _  ___  _ __  ___ 
#   \ \/ / _ \ '__/ __| |/ _ \| '_ \/ __|
#    \  /  __/ |  \__ \ | (_) | | | \__ \
#     \/ \___|_|  |___/_|\___/|_| |_|___/
#                                        
#                                        
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}