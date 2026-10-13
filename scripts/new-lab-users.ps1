# Creates lab users from users.csv in their department OU
$base = "DC=corp,DC=tclab,DC=internal"
$pw = Read-Host "Temporary password" -AsSecureString
Import-Csv C:\Lab\users.csv | ForEach-Object {
$u = @{
  Name                  = "$($_.First) $($_.Last)"
  GivenName             = $_.First
  Surname               = $_.Last
  SamAccountName        = $_.Sam
  UserPrincipalName     = "$($_.Sam)@corp.tclab.internal"
  Department            = $_.Dept
  Path                  = "OU=$($_.Dept),OU=Staff,OU=Lab,$base"
  AccountPassword       = $pw
  Enabled               = $true
  ChangePasswordAtLogon = $true
}
New-ADUser @u
}
