<#
    .NOTES
    https://github.com/equelin/vmware-powercli-workflows
#>

Function Get-DestinationNetwork {
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
        $VMList,

        # VM Networks adapters list
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $NetworkAdapters
    )

    Process {

        Foreach ($networkAdapter in $NetworkAdapters) {

            Write-Verbose -Message "[$($VM.Name)] Select destination portgroup for network card $($networkAdapter.Name)"

            If ($portgroup = $cfg.portgroup | Where-Object {$_.source -eq $networkAdapter.NetworkName}) {
                Write-Verbose "Select portgroup from translation table"
                Write-Host "`tNetwork card: [$($networkAdapter.Name)] Source portgroup: [$($networkAdapter.NetworkName)] Destination portgroup: [$($portgroup.destination)]" -ForegroundColor Blue
                Get-VMPortgroup -Name $portgroup.destination -Server $destVCConn
            } else {
                Write-Host "`tNetwork card: [$($networkAdapter.Name)] Source portgroup: [$($networkAdapter.NetworkName)] Destination portgroup: [$($networkAdapter.NetworkName)]" -ForegroundColor Blue
                Get-VMPortgroup -Name $networkAdapter.NetworkName -Server $destVCConn
            }
        } # End Foreach ($networkAdapter in $NetworkAdapter)
    } # End Process
} # End Function