$tenantName= "nrt"
$hostpool = "pool1"
#Get-RdsHostPool -TenantName $tenantName -Name $hostpool
#Get-RdsAppGroup -TenantName $tenantName -HostPoolName $hostpool
$Thumbprint = "BBBC38ED74F21B8427B162AF80A4F17282D8340F"
$TenantId = "5231c81b-959c-4621-a7bd-6635103652e7"
$ApplicationId = "21cb4b5f-f455-4333-b6ac-86671ffa987b"
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
#Get-RdsAppGroup -TenantName $tenantName -HostPoolName $hostpool
Get-RdsHostPool -TenantName $tenantName -HostPoolName $hostpool
Get-RdsSessionHost -TenantName $tenantName -HostPoolName $hostpool
#$Credential = Get-Credential
#add-rdsaccount -deploymenturl "https://rdbroker.wvd.microsoft.com"
#john.woods.adm@nrtbus.onmicrosoft.com
#cybjoW*0102

