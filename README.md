### **DISCLAIMER**

This script is not affiliated with or supported by Microsoft

# Suspend all Fabric capacities

## Azure Automation Runbook setup

### 1 – Create an Automation account

- Go to the Azure Portal
- Search for Automation Accounts 
- Select Create
- Choose the Resource Group, name and region
- Click on Next and, under Advanced, enable System-assigned Managed Identity
- Create the account

### 2 – Assign RBAC permissions to the Managed Identity

- Open your Microsoft Fabric capacity in Azure
- Go to Access control (IAM)
- Select Add role assignment – Privileged administrator roles
- Choose a role with: Microsoft.Fabric/capacities/read and Microsoft.Fabric/capacities/suspend/action

I recommend assigning the Contributor role

- In the Members tab, select Managed identity

### 3 – Import the required modules

- Go to your Automation Account and select Modules
- Select Browse from gallery and search for Az.Fabric
- Pick Runtime version 7.2

### 4 – Create the runbook and schedule

- Go to your Automation Account and select Runbooks
- Select Create runbook 
- Pick Runbook type PowerShell and Runtime version 7.2
- Go back to the main page of the Automation Account and under Shared Resources, click on Schedules – Add a new schedule

### Reference: 
The script reuses code from https://github.com/jugi92/suspend_or_resume_fabric_capacity_runbook

The advantages of my script are the fact it incorporates error handling and loops through all Fabric capacities of an Azure subscription, without the need to provide parameters.
