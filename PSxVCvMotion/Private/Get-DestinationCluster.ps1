Function Get-DestinationCluster {
    [CmdletBinding()]
    Param  (
        # Config object
        [Object]$cfg,

        # Source vCenter connexion object
        $sourceVCConn,

        # destination vCenter connexion object
        $destVCConn,

        # VM list
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