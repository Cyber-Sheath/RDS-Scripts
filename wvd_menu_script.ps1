
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
    Write-Host "Your current tenant: $rdsTenant "
    Write-Host "Your current host pool: $rdsHostPool "
    Write-Host ""
    Write-Host "L: Press 'L' to logon as a different RDS admin."
    Write-Host "T: Press 'T' to switch the RDS tenant or host pool."
    Write-Host ""
    Write-Host "Please select a menu item below:"
    Write-Host "1: Press '1' to list all logged in users."
    Write-Host "2: Press '2' to add a user to an app group."
    Write-Host "3: Press '3' to list all app groups."
    Write-Host "4: Press '4' to force a user logoff."
    Write-Host "5: Press '5' to get the number of logged on users."
    #Write-Host "6: Press '6' to show users logged on to a specific host."
    Write-Host "7: Press '7' to add a web browser to a user profile."
    Write-Host "8: Press '8' to remove a web browser from a user profile."
    Write-Host "Q: Press 'Q' to quit."
}
function check-rds-login{
    $rdsContext = Get-RdsContext -ErrorAction Stop
    return $rdsContext
}

function login-menu-rds-cert {
#import 
    Clear-Host
    Write-Host "================ Login with Azure Admin Credentials to Continue ================"
    $Thumbprint = "BBBC38ED74F21B8427B162AF80A4F17282D8340F"
    $TenantId = "5231c81b-959c-4621-a7bd-6635103652e7"
    $ApplicationId = "21cb4b5f-f455-4333-b6ac-86671ffa987b"
    $azAccount = Connect-AzureRMAccount -ServicePrincipal -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $Thumbprint 
    $rdsAccount = Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -AadTenantId $TenantId
}

################################################################################
#########################       Begin Application       ########################
################################################################################





#Initial login or validate already logged in
try {
    $rdsContext = check-rds-login
}
catch{
    $rdsAccount = login-menu-rds
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
        until (($selection -eq 'n') -or ($null -ne $rdsContext))#run until say N or auth goes through
        if ($selection -eq 'n'){break}
        
        #if authenticated prompt for and check account again tenant
    }
}


#validate credentials if new

#if no existin pool or tenant set
if (($null -eq $rdsHostPool) -or ($null -eq $rdsTenant)){
    $rdsTenant, $rdsHostPool = tenant-pool-menu
}


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
        pause

     }
     until (($selection -eq 'q') -or ($null -ne $userSession))#run until say N or auth goes through
     if ($selection -eq 'q'){break}
    
    
 }



###############################     Provides menu and executes commands based on selection
do
    {
        rds-menu
      
        $selection = Read-Host "Please make a selection"
        switch ($selection)
            {
                'L' {
                        $rdsAccount = login-menu-rds
                        $rdsContext = Get-RdsContext -ErrorAction Stop
                        $rdsUser = $rdsContext.UserName
                    } 
                'T' {
                        $rdsTenant, $rdsHostPool = tenant-pool-menu
                    }   
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
                '5' {
                    'number of logged in users'
                    $users = Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool
                    $users.count
                   }
                #'6' {
                    #'show all logged in users for a specific machine'
                    #list host names
                    #Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool | Format-Table SessionHostName -auto
                    #$hostName= Read-Host "Enter a host name: "
                #    $userReturn = Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool 
                    #Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool | where { $_.UserPrincipalName -eq $upn } | Invoke-RdsUserSessionLogoff -NoUserPrompt
                #}
                '7' {
                    'add web browser to user profile'
                    $upn = Read-Host "UPN for user ex. bsmith@nrtbus.com: "
                    Add-RdsAppGroupUser -TenantName $rdsTenant -HostPoolName $rdsHostPool -AppGroupName "BrowserAppGroup" -UserPrincipalName $upn
                    Get-RdsAppGroupUser -TenantName $rdsTenant -HostPoolName $rdsHostPool -AppGroupName "BrowserAppGroup" | Format-Table AppGroupName,UserPrincipalName -auto
                    #add browser app group
                    #Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool | where { $_.UserPrincipalName -eq $upn } | Invoke-RdsUserSessionLogoff -NoUserPrompt
                }
                '8' {
                    'remove web browser from user profile'
                    $upn = Read-Host "UPN for user ex. bsmith@nrtbus.com: "
                    #remove browser app group
                    Remove-RdsAppGroupUser -TenantName $rdsTenant -HostPoolName $rdsHostPool -AppGroupName "BrowserAppGroup" -UserPrincipalName $upn
                    Get-RdsAppGroupUser -TenantName $rdsTenant -HostPoolName $rdsHostPool -AppGroupName "BrowserAppGroup" | Format-Table AppGroupName,UserPrincipalName -auto
                    #Get-RdsUserSession -TenantName $rdsTenant -HostPoolName $rdsHostPool | where { $_.UserPrincipalName -eq $upn } | Invoke-RdsUserSessionLogoff -NoUserPrompt
                }
            }
            pause
        }
 until ($selection -eq 'q')
