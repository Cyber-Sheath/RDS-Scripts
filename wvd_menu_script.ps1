
#john.woods.


################################################################################
#########################       Variables   ####################################
################################################################################



################################################################################
#########################       Functions   ####################################
################################################################################



###############################     Login TO RDS 
function login-menu-rds {
    Clear-Host
    Write-Host "================ Login with Remote Desktop Admin Credentials to Continue ================"
    $rdsAccount = Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
    return $rdsAccount
}



###############################     Enter Tenant and Host Pool Info
function tenant-pool-menu {
    Write-Host "================ Enter Tenant & Host Pool Information ================"
    $rdsTenant = Read-Host "Please enter the RDS Tenant you wish to access: "
    $rdsHostPool = Read-Host "Please enter the RDS Host Pool you wish to access: "
    return $rdsTenant, $rdsHostPool
}



###############################     RDS Menu Options
function rds-menu {
    Clear-Host
    Write-Host "================ RDS Menu ================"
    Write-Host "Welcome $rdsUser, make a selection below for what you want to do: "
    Write-Host "1: Press '1' to list all logged in users."
    Write-Host "2: Press '2' to add a user to an app group."
    Write-Host "3: Press '3' to list all app groups."
    Write-Host "4: Press '4' to force a user logoff."
    Write-Host "Q: Press 'Q' to quit."
}





################################################################################
#########################       Begin Application       ########################
################################################################################



###############################     Login to azure if not already logged in.
Clear-Host

#Write-Host "================ Login with Azure Admin Credentials to Continue ================"
#$azAccount = Connect-AzureRMAccount


#show login screen
#$azAccount = login-menu-azure
$rdsAccount = login-menu-rds

#only used for testing

try {
    #test credentials
    $rdsContext = Get-RdsContext -ErrorAction Stop
}
catch {
    Write-Host "Login failed"
    do
    {
        $selection = Read-Host "Try Again? (Y/N)"
        #login failed, run login again is select Y otherwise break
        if ($selection -ne 'n'){$rdsContext = Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"}
        
    }
    until (($selection -eq 'n') -or ($rdsContext -ne $null))#run until say N or auth goes through
    if ($selection -eq 'n'){break}
    
    #if authenticated prompt for and check account again tenant
}


$rdsTenant, $rdsHostPool = tenant-pool-menu
Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool
Clear-Host
$rdsUser = $rdsContext.UserName
try {#try tenant and pool info for given user
    $userSession = Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool -ErrorAction Stop
    #try command to test auth to tenant and pool
}
catch {
    do
    {
    

        Write-Host "$rdsUser doesn't have acces to the Tenant: $rdsTenant and/or Host Pool: $rdsHostPool"
        Write-Host "1: Press '1' to login as a different RDS user."
        Write-Host "2: Press '2' to try a different tenant and host pool."
        Write-Host "Q: Press 'Q' to quit."
        #user doesn't have access to given tenant or pool
        #retry tenant & pool, or sign in as different user
        $selection = Read-Host "Please make a selection"
        switch ($selection)
        {
            '1' {
                $rdsAccount = login-menu-rds
                $rdsContext = Get-RdsContext -ErrorAction Stop
                $rdsUser = $rdsContext.UserName
            }
            '2' {
                $rdsTenant, $rdsHostPool = tenant-pool-menu
            }
        }
        $userSession = Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool
        $rdsContext
        $rdsTenant
        $rdsHostPool
        $userSession
        pause

     }
     until (($selection -eq 'n') -or ($userSession -ne $null))#run until say N or auth goes through
     if ($selection -eq 'n'){break}
    
    
 }



###############################     Provides menu and executes commands based on selection
do
    {
        rds-menu
      
        $selection = Read-Host "Please make a selection"
        switch ($selection)
            {
                '1' {
                        'get logged in users'
                        Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool
                    } 
                '2' {
                        'add a user to an app group'
                        $appGroupName = Read-Host "App Group Name: "
                        $upn = Read-Host "UPN for user ex. bsmith@nrtbus.com: "
                        Add-RdsAppGroupUser -TenantName $rdsTenant -HostPoolName $rdsHostPool -AppGroupName $appGroupName -UserPrincipalName $upn
                    } 
                '3' {
                        'show all app groups'
                        Get-RdsAppGroup -TenantName $rdsTenant -HostPoolName $rdsHostPool
                    }
                '4' {
                        'logoff a user'
                        $upn = Read-Host "UPN for user to logoff ex. bsmith@nrtbus.com: "
                        Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool | where { $_.UserPrincipalName -eq $upn } | Invoke-RdsUserSessionLogoff -NoUserPrompt
                    }
            }
            pause
        }
 until ($selection -eq 'q')
