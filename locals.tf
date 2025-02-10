# Define Python Packages with External URLs
locals {
  python_packages = {
    "azure_core"            = "https://files.pythonhosted.org/packages/39/83/325bf5e02504dbd8b4faa98197a44cdf8a325ef259b48326a2b6f17f8383/azure_core-1.32.0-py3-none-any.whl"
    "azure_identity"        = "https://files.pythonhosted.org/packages/f0/d5/3995ed12f941f4a41a273d9b1709282e825ef87ed8eab3833038fee54d59/azure_identity-1.19.0-py3-none-any.whl"
    "azure_mgmt_automation" = "https://files.pythonhosted.org/packages/57/40/0bec283c0e093714e85e582244935c21c3baf5fd947252221b3edf4cc75a/azure_mgmt_automation-1.0.0-py2.py3-none-any.whl"
    "azure_mgmt_core"       = "https://files.pythonhosted.org/packages/ab/2d/762b027cfd58b1b2c9b5b60d112615bd04bc33ef85dac55d2ee739641054/azure_mgmt_core-1.5.0-py3-none-any.whl"
    "azure_mgmt_network"    = "https://files.pythonhosted.org/packages/14/68/d1604383635f1f1b16cd7f1e27004db40a1f0493c57b2da9fb36dc775a79/azure_mgmt_network-28.1.0-py3-none-any.whl"
    "azure_storage_blob"    = "https://files.pythonhosted.org/packages/74/3c/3814aba90a63e84c7de0eb6fdf67bd1a9115ac5f99ec5b7a817a5d5278ec/azure_storage_blob-12.24.1-py3-none-any.whl"
  }
}

# Read `config.json` from the source folder
locals {
  config_data      = jsondecode(file("${path.module}/source/config.json"))
  subscription_ids = toset(local.config_data.subscription_ids) # Extract subscription IDs
}