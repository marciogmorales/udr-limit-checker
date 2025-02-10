# 🚀 Automating Azure UDR Limit Checks with Terraform and Azure Automation  

[![Medium Blog](https://img.shields.io/badge/Read%20More%20on-Medium-blue?logo=medium)](https://medium.com/your-blog-link)  

This repository contains a Terraform module that automates **Azure UDR (User Defined Routes) limit checks** using **Azure Automation and Runbooks**. The module provisions an Azure **Storage Account, Automation Account, Runbook, and Role Assignments** to scan multiple subscriptions and generate a CSV report.

---

## 📌 **What This Terraform Module Deploys**  

1️⃣  **Azure Blob Storage** – Deploys a secure storage account.  
2️⃣  **Storage Container** – Creates a private storage container.  
3️⃣  **Configuration File Upload** – Uploads `config.json` containing Subscription IDs.  
4️⃣  **Azure Automation Setup** – Deploys an **Azure Automation Account**, a **Python Runbook**, and necessary **variables**.  
5️⃣  **Role Assignments** – Grants the Azure Automation Account identity **necessary permissions** for the subscriptions listed in `config.json`.  
6️⃣  **Runbook Execution** – When executed, the Runbook **scans UDR limits** and stores the **output CSV file** in the **Storage container**.  

---

## 🚀 **Quick Setup Guide**  

### **1️⃣ Clone the Repository**  
```bash
git clone https://github.com/your-repo-name.git
cd your-repo-name
```

### **2️⃣ Modify the Configuration Files**

- Terraform Variables File **(variables.tf)** – Customize based on your preferences.
- Configuration File **(config.json)** – Add the Subscription IDs for the Runbook to scan. The file is located at: `path/source/config.json`

### **3️⃣ Deploy the Infrastructure**
Run the following Terraform commands:

```
terraform init
terraform plan
terraform apply -auto-approve
```

### **4️⃣ Start the Runbook**
After deployment, navigate to Azure Automation and manually start the Runbook:

🔹 UDR-LIMIT-CHECKER

### **5️⃣ View the Output**
Once the Runbook executes, a CSV file containing UDR details will be stored in the Azure Storage container.
