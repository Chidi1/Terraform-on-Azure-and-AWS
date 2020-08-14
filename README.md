# Terraform-on-Azure
Deploy resources to Azure and AWS using terraform
Terraform Deployment on Azure DevOps
Prepare your environment: Follow the steps below to install terraform on windows machine (used in my case)
A.	To install Terraform with Chocolatey, do the following steps:
1.	Open a PowerShell prompt as an administrator (click on the start menu > type PowerShell > right click > select more > run as administrator) and install Chocolatey using the command below
•	Get-ExecutionPolicy. If it returns Restricted, then run Set-ExecutionPolicy AllSigned or Set-ExecutionPolicy Bypass and select “yes to all”.
•	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

2.	Once that is complete, run “choco install terraform”. If you like, you can also put -y on the end to auto-agree to installing it on your device.
3.	Verify the installation was successful by entering terraform –version

B.	Create a resource group on Azure
Run the following PowerShell commands to connect to azure AD via PowerShell and create a resource group (edit the variables)
•	Connect-AzAccount  //connect
•	Set-AzContext xxxx xxxxx xxxxx xxxxxx xxxxx   //to set subscription id
•	New-AzResourceGroup -Name “type_your_resource_group_name_here (teliosRG for my case)” -Location "type_your_resource_group_location_here"  

C.	Create a service principal 
•	New-AzADServicePrincipal -DisplayName <type_preffered_name_here> -role contributor -scope /subscriptions/type_subscription_id_here (displayed when you successfully connected to azure ad using the previous command)/resourceGroups/ type_your_resource_group_name_here
Note: The returned object contains the Secret member, which is a SecureString containing the generated password. Make sure that you store this value somewhere secure to authenticate with the service principal. Its value won't be displayed in the console output.
You can run the following code will allow you to export the secret and save in your desired location: 
•	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
               $UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

D.	Create a storage account to store your terraform files.
•	New-AzStorageAccount -ResourceGroupName <type_your_resource_group_name_here> -Name <type_name_of_storage_account_here> -Location "Central US" -SkuName Standard_RAGRS -Kind StorageV2

E.	Get the storage account key and save in a secured file
•	Get-AzStorageAccountKey -ResourceGroupName "<type_your_resource_group_name_here> " -AccountName "<type_name_of_storage_account_here> " 

F.	Set the context of the storage account for blob
•	Set-AzCurrentStorageAccount -ResourceGroupName ""<type_your_resource_group_name_here> " -AccountName "<type_name_of_storage_account_here> "

G.	Create a storage blob/container
•	New-AzStorageContainer -Name <type_your_storage_container_name_here>  -Permission blob

H.	Create Azure DevOps account using the link below
•	https://azure.microsoft.com/en-us/services/devops/?nav=min

I.	Create a project and a service connection to your service principal on azure DevOps environment
•	Go to projects > projects settings > service connection > create service connection > Azure resource manager > service principal

J.	Create a repo on azure DevOps 
•	Go to repo > repo drop down menu > new repo

K.	Add terraform extension for DevOps pipeline  
•	Go to marketplace on DevOps interface > search for terraform (Microsoft devlabs) and install

L.	Create a terraform files for your deployments (app and VM). See files in this repo

M.	Install terraform tools

•	Click on show assistance to install terraform tools
•	Add terraform tools for init, validate, plan, validate and apply (add destroy if you want to end)
