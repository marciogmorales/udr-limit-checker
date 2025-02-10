import csv
import sys
import datetime
import json
import azure.identity
import azure.mgmt.network
import azure.storage.blob
import automationassets

from azure.identity import ManagedIdentityCredential
from azure.mgmt.network import NetworkManagementClient
from azure.storage.blob import BlobServiceClient

def load_config_from_blob(storage_account_name, container_name, blob_name):
    """Fetch the configuration JSON from an Azure Blob Storage container."""
    credential = ManagedIdentityCredential()
    blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net", credential=credential)
    blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
    config_data = blob_client.download_blob().readall().decode("utf-8")
    return json.loads(config_data)

def list_route_tables(subscription_ids, storage_account_name, container_name):
    """List all route tables across multiple subscriptions and store the data in a single CSV file in an Azure Blob."""
    credential = ManagedIdentityCredential()
    blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net", credential=credential)
    
    csv_data = "Resource Group,Route Table Name,Route Table ID, Subscription ID, UDR Count, Virtual Network\n"
    
    for subscription_id in subscription_ids:
        network_client = NetworkManagementClient(credential, subscription_id)
        
        for route_table in network_client.route_tables.list_all():
            resource_group = route_table.id.split("/resourceGroups/")[1].split("/")[0]
            routes = list(network_client.routes.list(resource_group, route_table.name))
            
            vnet_name = "N/A"
            for vnet in network_client.virtual_networks.list(resource_group):
                for subnet in network_client.subnets.list(resource_group, vnet.name):
                    if subnet.route_table and subnet.route_table.id == route_table.id:
                        vnet_name = vnet.name
                        break
                if vnet_name != "N/A":
                    break
            
            csv_data += f"{resource_group},{route_table.name},{route_table.id},{subscription_id},{len(routes)},{vnet_name}\n"
    
    # Generate blob name with current date and time
    timestamp = datetime.datetime.now().strftime("%m%d%Y_%H%M%S")
    blob_name = f"{timestamp}_UDR_LIMIT_CHECKER.csv"
    
    # Upload CSV to Azure Storage Blob
    blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
    blob_client.upload_blob(csv_data, overwrite=True)
    
    print(f"CSV file '{blob_name}' uploaded successfully.")

if __name__ == "__main__":
    try:
        # Fetch Automation Variables from Azure Automation Account
        STORAGE_ACCOUNT_NAME = automationassets.get_automation_variable("AZURE_STORAGE_ACCOUNT")
        CONTAINER_NAME = automationassets.get_automation_variable("AZURE_CONTAINER_NAME")
        CONFIG_BLOB_NAME = "config.json"  # JSON file stored in the container

        if not STORAGE_ACCOUNT_NAME or not CONTAINER_NAME:
            raise ValueError("AZURE_STORAGE_ACCOUNT or AZURE_CONTAINER_NAME Automation Variables are not set.")

        # Load the config from blob storage
        config = load_config_from_blob(STORAGE_ACCOUNT_NAME, CONTAINER_NAME, CONFIG_BLOB_NAME)

        # Extract necessary configuration values from automation assets
        STORAGE_ACCOUNT_NAME = automationassets.get_automation_variable("AZURE_STORAGE_ACCOUNT")
        CONTAINER_NAME = automationassets.get_automation_variable("AZURE_CONTAINER_NAME")
        SUBSCRIPTION_IDS = config["subscription_ids"]
        
        list_route_tables(SUBSCRIPTION_IDS, STORAGE_ACCOUNT_NAME, CONTAINER_NAME)

    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)
