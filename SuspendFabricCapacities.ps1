# Azure Automation PowerShell Runbook - Suspend all Fabric capacities using the Fabric REST API

# Import necessary Azure modules for authentication and resource management
Import-Module Az.Accounts -Force -ErrorAction Stop
Import-Module Az.Resources -Force -ErrorAction Stop

# Authenticate using the system-assigned managed identity (no need for credentials)
Connect-AzAccount -Identity | Out-Null

# Ensure a subscription context is set; if not, pick the first active subscription
if (!(Get-AzContext).Subscription) {
    $sub = Get-AzSubscription -SubscriptionStatus Active | Select-Object -First 1
    if ($sub) { Set-AzContext -SubscriptionId $sub.Id | Out-Null }
}

# Retrieve all Microsoft Fabric capacities in the current subscription
$capacities = Get-AzResource -ResourceType "Microsoft.Fabric/capacities"

# Get an Azure Resource Manager (ARM) bearer token for authentication in REST API calls
$tokenResponse = Get-AzAccessToken -ResourceUrl "https://management.azure.com/"
$token = $tokenResponse.Token

# If the token is a SecureString, convert it to plain text
if ($token -is [System.Security.SecureString]) {
    $token = [System.Net.NetworkCredential]::new("", $token).Password
}

# Prepare HTTP headers for the REST API call
$headers = @{ 
    "Authorization" = "Bearer $token"; 
    "Content-Type" = "application/json" 
}

# Loop through each Fabric capacity and send a POST request to suspend it
foreach ($cap in $capacities) {
    $capName = $cap.Name
    $rgName  = $cap.ResourceGroupName
    $capId   = $cap.ResourceId   # Full resource ID path

    Write-Output "Suspending capacity: $capName (Resource Group: $rgName)..."

    # Construct the REST API URL for suspending the capacity
    $url = "https://management.azure.com${capId}/suspend?api-version=2023-11-01"

    try {
        # Send the suspend request
        Invoke-RestMethod -Uri $url -Method POST -Headers $headers -ErrorAction Stop
        Write-Output "✅ Suspended: ${capName}"
    }
    catch {
        # Handle errors, including if the capacity is already paused
        $errorMsg = $_.ToString()
        if ($errorMsg -match "Service is not ready to be updated") {
            Write-Output "⏭️ Skipped (already paused): ${capName}"
        }
        else {
            Write-Error "❌ Failed to suspend ${capName}: $errorMsg"
        }
    }
}