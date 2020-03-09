#Script: Adds DataCenter IPs from Azure XML to Azure Network Security Group. 
#Readme: Pleae Provide Azure SubscriptionID, ResourceGroup Name, NSG Name and Rule Priority. 
#Note: ResourceGroup and NSG must exist. 
 
$subscriptionId = Read-Host 'Specify your Azure Subscription ID?'; 
$rgName = Read-Host 'Specify the name of the Resource group in which your NSG is located'; 
$nsgname = Read-Host 'Specify the name of the NSG'; 
 
do { 
    try { 
        $numOk = $true; 
        [int]$rulePriority = Read-Host 'Specify the Priority for NSG Rules between 100 to 4096'; 
        } 
    catch {$numOK = $false;} 
    } 
until (($rulePriority -ge 100 -and $rulePriority -lt 4096) -and $numOK) 
 
# Sign-in with Azure account credentials 
Login-AzureRmAccount; 
 
# Select Azure Subscription 
Select-AzureRmSubscription -SubscriptionId $subscriptionId; 
 
# Download current list of Azure Public IP ranges 
$downloadUri = "https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653"; 
$downloadPage = Invoke-WebRequest -Uri $downloadUri; 
$xmlFileUri = ($downloadPage.RawContent.Split('"') -like "https://*PublicIps*")[0]; 
$response = Invoke-WebRequest -Uri $xmlFileUri; 
 
# Get list of regions & public IP ranges 
[xml]$xmlResponse = [System.Text.Encoding]::UTF8.GetString($response.Content); 
$regions = $xmlResponse.AzurePublicIpAddresses.Region; 
 
# Select Azure regions for which to define NSG rules 
$selectedRegions = $regions.Name | Out-GridView -Title "Select Azure Datacenter Regions …" -PassThru; 
$ipRange = ( $regions | where-object Name -In $selectedRegions ).IpRange; 
 
# Build NSG rules 
$rules = @() 
$nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgname -ResourceGroupName $rgName -ErrorAction:SilentlyContinue; 
 
if ($NSG) { 
    ForEach ($subnet in $ipRange.Subnet) { 
        $ruleName = "Allow_Azure_Out_" + $subnet.Split("/")[0]; 
        try { 
            Get-AzureRmNetworkSecurityGroup -Name $nsgname -ResourceGroupName $rgName -ErrorAction:Stop | Add-AzureRmNetworkSecurityRuleConfig -Name $ruleName -Description "Allow outbound to Azure $subnet" -Access Allow -Protocol * -Direction Outbound -Priority $rulePriority -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix "$subnet" -DestinationPortRange * -ErrorAction:Stop | Set-AzureRmNetworkSecurityGroup -ErrorAction:Stop | Out-NULL; 
            $rulePriority++; 
            Write-Host "Info: $ruleName was added to NSG"; 
        } catch { 
            Write-Host "Error: Failed to add Rule: $ruleName"; 
        } 
    } 
} else { 
    Write-Host "Error: Not NSG Found"; 
}
