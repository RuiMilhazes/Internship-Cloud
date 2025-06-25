#  _____                _     _               
# |  __ \              (_)   | |              
# | |__) | __ _____   ___  __| | ___ _ __ ___ 
# |  ___/ '__/ _ \ \ / / |/ _` |/ _ \ '__/ __|
# | |   | | | (_) \ V /| | (_| |  __/ |  \__ \
# |_|   |_|  \___/ \_/ |_|\__,_|\___|_|  |___/
#                                             
#                                             
provider "azurerm" {
  # Configuration options
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = "0cf2fa8e-27a5-4721-9801-2fa98f8b8c3e"
}

provider "random" {
}