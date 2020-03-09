$upnSuffix = Read-Host -Prompt 'Enter New UPN Suffix'
$LocalUsers = Get-ADUser -Filter {UserPrincipalName -like (Get-ADForest).Name} -Properties userPrincipalName -ResultSetSize $null
$LocalUsers | foreach {$newUpn = $_.UserPrincipalName.Replace((Get-ADForest).Name,$upnSuffix); $_ | Set-ADUser -UserPrincipalName $newUpn}