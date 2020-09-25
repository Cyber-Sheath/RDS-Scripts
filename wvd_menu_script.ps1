

function login-menu {
    Clear-Host
    Write-Host "================ Login with Remote Desktop Admin Credentials to Continue ================"
    Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
    #Write-Host "You are currently $loggedIn"
    #Write-Host "1: Press 'Y' to continue"
    #Write-Host "Q: Press 'Q' to quit."
}
#try {
#    Get-RdsContext -ErrorAction Stop
#}
#catch {
#    Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
#}

#Do RDS auth
#do
# {
#    login-menu
#    
#    $selection = Read-Host "Please make a selection"
#    switch ($selection)
#    {
#    'Y' {
#        Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
#    }
#    }
#    pause
# }
# until ($selection -eq 'q')
# if ($selection -eq 'q'){break}

login-menu
try {

    $rdsContext = Get-RdsContext -ErrorAction Stop
}
catch {
    Write-Host "Login failed"
    do
    {
        $selection = Read-Host "Try Again? (Y/N)"
        if ($selection -ne 'n'){$rdsContext = Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"}
        
    }
    until (($selection -eq 'n') -or ($rdsContext -ne $null))
    if ($selection -eq 'n'){break}
    

}

function rds-info-menu {
    Clear-Host
    Write-Host "================ Collecting RDS Info ================"
    Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
    #Write-Host "You are currently $loggedIn"
    #Write-Host "1: Press 'Y' to continue"
    #Write-Host "Q: Press 'Q' to quit."
}
$rdsTenant = Read-Host "Please enter the RDS Tenant you wish to access: "
$rdsHostPool = Read-Host "Please enter the RDS Host Pool you wish to access: "
    
$rdsUser = $rdsContext.UserName
function rds-menu {
    Clear-Host
    Write-Host "================ RDS Menu ================"
    Write-Host "Welcome $rdsUser, make a selection below for what you want to do: "
    Write-Host "1: Press '1' to list the number of logged on users."
    Write-Host "2: Press '2' to show where a specific user is logged in."
    Write-Host "3: Press '3' to show all users logged into a specific machine."
    Write-Host "4: Press '4' to add a user to the default app group."
    Write-Host "5: Press '5' to add a web browser to a user profile."
    Write-Host "6: Press '6' to remove a web browser from a user profile."
    Write-Host "7: Press '7' to force a user logoff."
    Write-Host "Q: Press 'Q' to quit."
}

do
 {
    

    rds-menu
    
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    'list logged in users'
    } 
    '2' {
    'show where a user is logged in'
    } 
    '3' {
      'show all users logged into cp'
    }
    '4' {
    'adding a user to the default app group'
    } 
    '5' {
    'adding web browser to user profile'
    } 
    '6' {
      'remove web browser from user profile'
    }
    '7' {
      'force user logoff'
    }

    }
    pause
 }
 until ($selection -eq 'q')