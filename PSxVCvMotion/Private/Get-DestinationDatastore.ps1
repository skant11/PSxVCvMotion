Function Get-DestinationDatastore {
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

        $datastorename = ($vm | Get-Datastore -Server $sourceVCConn).Name | Select-Object -First 1

        If ($datastore = $cfg.datastore | Where-Object {$_.source -eq $datastorename}) {
            Write-Verbose "Select Datastore from translation table"
            $destinationDatastore = Get-Datastore $datastore.destination -Server $destVCConn | Sort-Object -Descending -Property 'FreeSpaceGB' | Select-Object -First 1
        } else {
            $destinationDatastore = Get-Datastore $datastorename -Server $destVCConn 
        }
        
        Write-Host "`tSource datastore: [$datastorename] Destination datastore: [$($destinationDatastore.Name)]" -ForegroundColor Blue

        return $destinationDatastore

    }
}