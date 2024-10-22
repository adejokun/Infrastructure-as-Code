## Virtual Machine Availability Set with Key Vault
___________________________________________________

This template deploys a Virtual Machine Availabiltiy Set in Azure having a randonmized password stored in a key vault. Furthermore, the terraform statefile is stored in a storage account to enable remote access to all collaborators

Steps are given below:

1. Creates a virtual machine availability Set 
2. Creates a random password that will be used as the password for the VM
3. Creates an Azure Key Vault that will store the password for the VM
4. Stores the terraform state file in a 'backend' storage account in the cloud