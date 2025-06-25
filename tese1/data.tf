#   _____        _  
#  |  __ \      | |  
#  | |  | | __ _| |_ __ _
#  | |  | |/ _` | __/ _` |
#  | |__| | (_| | || (_| |
#  |_____/ \__,_|\__\__,_|
#  
#* Section: Data
# This is to load Tags from an Yaml file
data "local_file" "common_tags" {
  filename = "${path.cwd}/common_tags.yaml"
}

# This is to retrieve current user config, like tenantId.
data "azurerm_client_config" "current" {
}