# Usage:
# Run as: .\backupExportPolicyRules.ps1 -server <mgmt_ip> -user <mgmt_user> -password <mgmt_user_password> -vserver <vserver name> -exportPolicyFile <xml file to store export policies> -exportRuleFile <xml file to store export policy rules> -spit <none,less,more depending on info to print>
#
# Example
# 1. If you want to save exports on vserver vs2 and display more output
# Run as: .\backupExportPolicyRules.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -exportPolicyFile C:\export.xml -exportRuleFile C:\rules.xml -spit more 
#
# 2. If you want to save exports to a csv file for examination
# Run as: .\backupExportPolicyRules.ps1 -s 10.53.33.59 -u admin -p netapp1! -v vs2 -ep C:\share.csv -er C:\rules.csv -spit more -csv true

Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver,
      [parameter(Mandatory = $true)] [alias("ep")] $exportPolicyFile,
      [parameter(Mandatory = $true)] [alias("er")] $exportRuleFile,
      [parameter(Mandatory = $true)] [alias("sp")] [Validateset("none","less","more")] $spit,
      [Validateset("false","true")] $csv = "false")

Import-Module C:\Windows\system32\WindowsPowerShell\v1.0\Modules\DataOnTap

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}

#Get export policies and export to a file
if ($csv -eq "false") {
    Get-NcExportPolicy -Controller $nctlr -VserverContext $vserver | Export-Clixml $exportPolicyFile
} else {
    Get-NcExportPolicy -Controller $nctlr -VserverContext $vserver | Export-Csv $exportPolicyFile
}

#Display Exports
if ($spit -ne "none")
{
    echo "`n************************EXPORT POLICIES START*****************************************"
    if ($spit -eq "more")
    {
        Import-Clixml $exportPolicyFile | Format-List
    }
    else
    {
        Import-Clixml $exportPolicyFile
    }
    echo "************************EXPORT POLICIES END*****************************************`n"

}

#Get nfs protocol export rules and output to a file
if ($csv -eq "false") {
    Get-NcExportRule -Controller $nctlr -VserverContext $vserver | Export-Clixml $exportRuleFile
} else {
    Get-NcExportRule -Controller $nctlr -VserverContext $vserver | Export-Csv $exportRuleFile
}

#Display protocol Export rules
if ($spit -ne "none")
{
    echo "`n************************EXPORT RULES START*****************************************"
    if ($spit -eq "more")
    {
        Import-Clixml $exportRuleFile | Format-List
    }
    else
    {
        Import-Clixml $exportRuleFile
    }
    echo "************************EXPORT RULES END*****************************************`n"

}
