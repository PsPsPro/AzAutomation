param (
    [string]$OutputPath = ".\AzureResourcesWithoutTags.tsv"
)

$clientId = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET
$tenantId = $env:AZURE_TENANT_ID
$subscriptionId = $env:AZURE_SUBSCRIPTION_ID

$securePassword = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$credentials = New-Object -TypeName "Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureCredential" -ArgumentList $clientId, $securePassword, $tenantId, "ServicePrincipal"

# Connect to Azure using Service Principal
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId

$output = @()

# Set context to the subscription
Set-AzContext -SubscriptionId $subscriptionId

# Get all resources in the subscription
$resources = Get-AzResource

# Filter resources without tags
$resourcesWithoutTags = $resources | Where-Object { $_.Tags.Count -eq 0 }

# Loop through each resource without tags
foreach ($resource in $resourcesWithoutTags) {
    $output += [PSCustomObject]@{
        SubscriptionName = $subscriptionId
        SubscriptionId   = $subscriptionId
        ResourceName     = $resource.Name
        ResourceGroup    = $resource.ResourceGroupName
        ResourceType     = $resource.ResourceType
        ResourceLocation = $resource.Location
    }
}

# Export the output to a tab-separated CSV file
$output | Export-Csv -Path $OutputPath -Delimiter "`t" -NoTypeInformation

Write-Host "Export completed. File saved at: $OutputPath"
