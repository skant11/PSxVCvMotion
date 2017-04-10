Function Get-DestinationVMHost {
    [CmdletBinding()]
    Param  (
        # Config object
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [Object]$cfg,

        # Source vCenter connexion object
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $sourceVCConn,

        # destination vCenter connexion object
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $destVCConn,

        # VM list
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $VM,

        # Destination cluster
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $Cluster
    )

    Process {

        Write-Verbose -Message "[$vmname] Get information about source VMHosts."
        $sourceVMHost = $VM | Get-VMHost -Server $sourceVCConn

        Write-Verbose -Message "[$vmname] Get information about destination VMHosts."
        $destination = $cluster | Get-VMHost -Server $destVCConn | Get-Random

        Write-Host "`tSource VMHost: [$($sourceVMHost.Name)] Destination VMHost: [$($destination.Name)]" -ForegroundColor Blue

        return $destination
    } # End Process
} # End Function