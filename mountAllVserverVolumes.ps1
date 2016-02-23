Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver)

Import-Module "C:\Program Files (x86)\Netapp\Data ONTAP PowerShell Toolkit\DataONTAP"

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}


get-ncVol -Vserver $vserver| foreach { 

   $myVol = $_.Name
     if (($myVol -ne $null) -and ($myVol -ne "") -and ($myVol -notlike "*root*") )
    {
         Mount-NcVol -vservercontext  svm_nfs_02 -name $myVol -JunctionPath "/$myVol"
    }
}