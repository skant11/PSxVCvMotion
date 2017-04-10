<#
    .NOTES
    https://github.com/equelin/vmware-powercli-workflows
#>

Function Get-DestinationCluster {
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
        $VM
    )

    Process {

        $sourcecluster = $VM | Get-Cluster

        If ($destinationcluster = $cfg.cluster | Where-Object {$sourcecluster.name -like $_.source}) {
            Write-Verbose "Select Cluster from translation table"
            $Cluster = Get-Cluster $destinationcluster.destination -Server $destVCConn
            Write-Host "`tSource cluster: [$($sourcecluster.Name)] Destination cluster: [$($cluster.Name)]" -ForegroundColor Blue
        } else {
            $Cluster = Get-Cluster $sourcecluster.Name -Server $destVCConn
            Write-Host "`tSource cluster: [$($sourcecluster.Name)] Destination cluster: [$($cluster.Name)]" -ForegroundColor Blue 
        }

        return $Cluster
    } # End Process
} # End Function