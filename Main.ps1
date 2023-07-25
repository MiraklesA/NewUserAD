$ErrorActionPreference = "Continue"


Write-Host "    _   __                __  __                  _____           _       __ 
   / | / ___ _      __   / / / ________  _____   / ___/__________(_____  / /_
  /  |/ / _ | | /| / /  / / / / ___/ _ \/ ___/   \__ \/ ___/ ___/ / __ \/ __/
 / /|  /  __| |/ |/ /  / /_/ (__  /  __/ /      ___/ / /__/ /  / / /_/ / /_  
/_/ |_/\___/|__/|__/   \____/____/\___/_/      /____/\___/_/  /_/ .___/\__/  
                                                               /_/           "

Write-Host "Last Updated 19/07/2023"

$FirstName = Read-Host -Prompt 'Input Users FirstName'
$LastName = Read-Host -Prompt 'Input Users LastName' 
$Logon = Read-Host -Prompt 'Input SAM Login' 
$JobTitle = Read-Host -Prompt "Input Users Jobtitle: "
$Inherit = Read-Host -Prompt "SAM Login for the Inherited Account: "
$email = "$FirstName.$LastName"

function NewUser {

# Assigns a variable to the replicated users attributes
$attributes = Get-ADUser -Identity $Inherit -Properties StreetAddress,City,PostalCode,Office,Department,Manager, POBox, City, State, Country

#Main line that creates a new user account
$ErrorActionPreference = "Stop"
New-ADUser -Name "$LastName, $FirstName" -GivenName $FirstName -Surname $LastName -SamAccountName $Logon -UserPrincipalName $email"@domain" -Instance $attributes -AccountPassword (ConvertTo-SecureString -AsPlainText “Password12345!” -Force) -ChangePasswordAtLogon $True -Company "Company Name" -Description $JobTitle -DisplayName "$Lastname, $FirstName" -Enabled $True -EmailAddress $email"@domain" -Title $JobTitle
Write-Host "User Account Created"
#Gets the SGs/DGs that the user is in and replicates them
$getusergroups = Get-ADUser –Identity $Inherit -Properties memberof | Select-Object -ExpandProperty memberof 

$getusergroups | Add-ADGroupMember -Members $Logon -verbose
Write-Host "Security Groups / DGS Imported"

#Move to the correct OU
Get-ADUser -Identity $Logon | Move-ADObject -TargetPath "OU=Users,DC=com
Write-Host "Moved to the correct OU"
}



function Exchange {
$ErrorActionPreference = "Continue"
$UserCredential = Get-Credential #login with DA acc
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://(Exchange Server Name)/powershell/ -Authentication  Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking
Write-Host $EDomain
Enable-Mailbox -Identity $email"@domain"
Remove-PSSession $Session
}


NewUser
Exchange

exit
