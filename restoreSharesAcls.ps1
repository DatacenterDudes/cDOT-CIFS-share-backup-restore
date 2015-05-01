# Usage:
# Run as: .\getSharesAcls.ps1 -server <mgmt_ip> -user <mgmt_user> -password <mgmt_user_password> -vserver <vserver name> -share <share name or * for all> -shareFile <xml file to store shares> -aclFile <xml file to store acls> -spit <none,less,more depending on info to print>
#
# Example
# 1. If you want to save only a single share on vserver vs2.
# Run as: .\getSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share test2 -shareFile C:\share.xml -aclFile C:\acl.xml -spit more 
#
# 2. If you want to save all the shares on vserver vs2.
# Run as: .\getSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share * -shareFile C:\share.xml -aclFile C:\acl.xml -spit less
#
# 3. If you want to save only shares that start with "test" and share1 on vserver vs2.
# Run as: .\getSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share "test* | share1" -shareFile C:\share.xml -aclFile C:\acl.xml -spit more

Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver,
      [parameter(Mandatory = $true)] [alias("sh")] $share,
      [parameter(Mandatory = $true)] [alias("sf")] $shareFile,
      [parameter(Mandatory = $true)] [alias("af")] $aclFile,
      [parameter(Mandatory = $true)] [alias("sp")] [Validateset("none","less","more")] $spit)

Import-Module C:\Windows\system32\WindowsPowerShell\v1.0\Modules\DataONTAP

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}

#Get all the shares and export to file
Get-NcCifsShare -Controller $nctlr -VserverContext $vserver -Name $share | Export-Clixml $shareFile

#Get all the acls and export to file
Get-NcCifsShareAcl -Controller $nctlr -VserverContext $vserver -Share $share | Export-Clixml $aclFile

#Display Shares and Acls saved
if ($spit -ne "none")
{
    echo "`n************************SHARES START*****************************************"
    if ($spit -eq "more")
    {
        Import-Clixml $shareFile | Format-List
    }
    else
    {
        Import-Clixml $shareFile
    }
    echo "************************SHARES END*****************************************`n"

    echo "************************ACLS START*****************************************"
    if ($spit -eq "more")
    {
        Import-Clixml $aclFile | Format-List
    }
    else
    {
        Import-Clixml $aclFile
    }

    echo "************************ACLS END*****************************************"

}
