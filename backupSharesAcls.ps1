# Usage:
# Run as: .\backupSharesAcls.ps1 -server <mgmt_ip> -user <mgmt_user> -password <mgmt_user_password> -vserver <vserver name> -share <share name or * for all> -shareFile <xml file to store shares> -aclFile <xml file to store acls> -spit <none,less,more depending on info to print>
#
# Example
# 1. If you want to save only a single share on vserver vs2.
# Run as: .\backupSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share test2 -shareFile C:\share.xml -aclFile C:\acl.xml -spit more 
#
# 2. If you want to save all the shares on vserver vs2.
# Run as: .\backupSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share * -shareFile C:\share.xml -aclFile C:\acl.xml -spit less
#
# 3. If you want to save only shares that start with "test" and share1 on vserver vs2.
# Run as: .\backupSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share "test* | share1" -shareFile C:\share.xml -aclFile C:\acl.xml -spit more
#
# 4. If you want to save shares and ACLs into .csv format for examination.
# Run as: .\backupSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -share *  -shareFile C:\shares.csv -aclFile C:\acl.csv -csv true -spit more
# 
# This has been tested with the latest 8.2.x and 8.3.x cDOT releases.

Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver,
      [parameter(Mandatory = $true)] [alias("sh")] $share,
      [parameter(Mandatory = $true)] [alias("sf")] $shareFile,
      [parameter(Mandatory = $true)] [alias("af")] $aclFile,
      [parameter(Mandatory = $true)] [alias("sp")] [Validateset("none","less","more")] $spit,
      [Validateset("false","true")] $csv = "false")

# You need to install the latest DataONTAP Powershell Toolkit. You can find it here: http://mysupport.netapp.com/NOW/download/tools/powershell_toolkit/
Import-Module DataONTAP

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}

#Get all the shares and export to file
if ($csv -eq "false") {
    Get-NcCifsShare -Controller $nctlr -VserverContext $vserver -Share $share | Export-Clixml $shareFile
} else {
    Get-NcCifsShare -Controller $nctlr -VserverContext $vserver -Share $share | Export-Csv $shareFile
}


#Get all the acls and export to file
if ($csv -eq "false") {
    Get-NcCifsShareAcl -Controller $nctlr -VserverContext $vserver -Share $share | Export-Clixml $aclFile
} else {
    Get-NcCifsShareAcl -Controller $nctlr -VserverContext $vserver -Share $share | Export-Csv $aclFile
}

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
