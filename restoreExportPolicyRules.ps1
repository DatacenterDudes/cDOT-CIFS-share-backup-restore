# Usage:
# Run as: .\restoreExportPolicyRules.ps1 -server <mgmt_ip> -user <mgmt_user> -password <mgmt_user_password> -vserver <vserver name> -exportPolicyFile <xml file to get exports from > -exportRuleFile <xml file to get export rules from> -spit <none,less,more depending on info to print> 
#
# Example
# 1. If you want to save create back exports from xml file C:\export.xml and acls from xml file C:\acls.xml on vserver vs2, with less information displayed on the screen 
# Run as:  .\restoreExportPolicyRules.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -exportPolicyFile C:\export.xml -exportRuleFile C:\rules.xml -spit less 
#
# 2. If you only want to print the commands and not actually create the exports, use -printOnly 
# Run as:  .\restoreExportPolicyRules.ps1 -s 10.53.33.59 -u admin -p netapp1! -v vs2 -ep C:\export.xml -er C:\acl.xml -dp less -po true

Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver,
      [parameter(Mandatory = $true)] [alias("ep")] $exportPolicyFile,
      [parameter(Mandatory = $true)] [alias("er")] $exportRuleFile,
      [parameter(Mandatory = $true)] [alias("sp")] [Validateset("none","less","more")]$spit,
      [alias("po")] [Validateset("false","true")] $printOnly = "false")
            
Import-Module C:\Windows\system32\WindowsPowerShell\v1.0\Modules\DataOnTap

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}

$new_policies = Import-Clixml -Path $exportPolicyFile

if ($spit -ne "none")
{
    echo "====================================================================================="
    echo "EXPORT POLICIES"
    echo "====================================================================================="

    if ($spit -eq "less")
    {
        $new_policies
    } 
    elseif ($spit -eq "more")
    {
        $new_policies | Format-List
    }
}
echo "====================================================================================="

$new_policies | foreach { 
   $mycmd = "New-NcExportPolicy -VserverContext $vserver"

   $myPolicyName = $_.PolicyName
   

    if (($myPolicyName -ne $null) -and ($myPolicyName -ne ""))
    {
        $mycmd = $mycmd + " -Name ""$myPolicyName"""          
    }

    if ($myPolicyName -eq "default") { $mycmd = "" } # don't create default export policy


    if ($spit -ne "none")
    {
        $mycmd
        echo "--------------------"
    }

    if (($printOnly -eq "false") -and ($myPolicyName -ne "default"))
    {
        Invoke-Expression $mycmd
    }
}

$new_rules = Import-Clixml -Path $exportRuleFile

if ($spit -ne "none")
{
    echo "====================================================================================="
    echo "EXPORT RULES"
    echo "====================================================================================="

    if ($spit -eq "less")
    {
        $new_rules
    } 
    elseif ($spit -eq "more")
    {
        $new_rules | Format-List
    }
}
echo "====================================================================================="

$new_rules | foreach { 
   $mycmd = "New-NcExportRule -VserverContext $vserver"


    if (($myPolicyName -ne $null) -and ($myPolicyName -ne ""))
    {
        $mycmd = $mycmd + " -Policy ""$myPolicyName"""          
    }

   $myRuleIndex = $_.RuleIndex
   
    if (($myRuleIndex -ne $null) -and ($myruleIndex -ne ""))
    {
        $mycmd = $mycmd + " -Index $myRuleIndex"          
    }

   $myProtocol = $_.Protocol
   
    if (($myProtocol -ne $null) -and ($myruleProtocol -ne ""))
    {
        $mycmd = $mycmd + " -Protocol ""$myProtocol"""          
    }

   $myClientMatch = $_.ClientMatch
   
    if (($myClientMatch -ne $null) -and ($myClientMatch -ne ""))
    {
        $mycmd = $mycmd + " -ClientMatch ""$myClientMatch"""          
    }

   $myAnonymousUserID = $_.AnonymousUserId
   
    if (($myAnonymousUserId -ne $null) -and ($myAnonymousUserId -ne ""))
    {
        $mycmd = $mycmd + " -Anon ""$myAnonymousUserId"""          
    }

   $myRoRule = $_.RoRule
   
    if (($myRoRule -ne $null) -and ($myRoRule -ne ""))
    {
        $mycmd = $mycmd + " -ReadOnlySecurityFlavor ""$myRoRule"""          
    }

   $myRwRule = $_.RwRule
   
    if (($myRwRule -ne $null) -and ($myRwRule -ne ""))
    {
        $mycmd = $mycmd + " -ReadWriteSecurityFlavor ""$myRwRule"""          
    }

   $mySuperUserSecurity = $_.SuperUserSecurity
   
    if (($mySuperUserSecurity -ne $null) -and ($mySuperUserSecurity -ne ""))
    {
        $mycmd = $mycmd + " -SuperUserSecurityFlavor ""$mySuperUserSecurity"""          
    }

   $myExportChownMode = $_.ExportChownMode
   
    if (($myExportChownMode -ne $null) -and ($myExportChownMode -ne ""))
    {
        $mycmd = $mycmd + " -ChownMode ""$myExportChownMode"""          
    }

   $myExportNtfsUnixSecurityOps = $_.ExportNtfsUnixSecurityOps
   
    if (($myExportNtfsUnixSecurityOps -ne $null) -and ($myExportNtfsUnixSecurityOps -ne ""))
    {
        $mycmd = $mycmd + " -NtfsUnixSecurityOps ""$myExportNtfsUnixSecurityOps"""          
    }

    $myIsAllowDevIsEnabled = $_.IsAllowDevIsEnabled

    if (($myIsAllowDevIsEnabled))
    {
        $mycmd = $mycmd + " -EnableDev"
    } 
    else 
    {
	$mycmd = $mycmd + " -DisableDev"
    }
    
    $myIsAllowSetUidEnabled = $_.IsAllowSetUidEnabled

    if (($myIsAllowSetUidEnabled))
    {
        $mycmd = $mycmd + " -EnableSetUid"
    } 
    else 
    {
	$mycmd = $mycmd + " -DisableSetUid"
    }
    

    if ($spit -ne "none")
    {
        $mycmd
        echo "--------------------"
    }

    if ($printOnly -eq "false")
    {
        Invoke-Expression $mycmd
    }
}

