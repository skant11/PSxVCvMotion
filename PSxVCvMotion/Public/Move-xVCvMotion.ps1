<#
    .NOTES
    https://github.com/equelin/vmware-powercli-workflows
#>

Function Move-xVCvMotion {
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
    Param  (
        # Config object
        [Object]$cfg,

        # Source vCenter connexion object
        $sourceVCConn,

        # destination vCenter connexion object
        $destVCConn,

        # VM list
        $VMList
    )

    Process {
        
        Foreach ($vmname in $VMList.Name) {

            If ($cfg.vm.exclusion -notcontains $vmname) {

                # Initialize variable
                $PortGroups = @()

                # Select VM
                Write-Host "Processing VM [$vmname]" -ForegroundColor Blue
                $VM = Get-VM $vmname -Server $sourceVCConn -erroraction SilentlyContinue

                if ($VM) {

                    # Select destination Cluster and VMHost
                    ## Get VM's cluster

                    Write-Verbose -Message "[$vmname] Select destination cluster."
                    $cluster = Get-DestinationCluster -Cfg $Cfg -sourceVCConn $sourceVCConn -destVCConn $destVCConn -VM $VM

                    ## Select destination VMHost

                    Write-Verbose -Message "[$vmname] Select destination VMHost."
                    $Destination= Get-DestinationVMHost -Cfg $Cfg -sourceVCConn $sourceVCConn -destVCConn $destVCConn -VM $VM -Cluster $Cluster

                    # Select destination datastore

                    Write-Verbose -Message "[$vmname] Select destination datastore."
                    $Datastore = Get-DestinationDatastore -Cfg $Cfg -sourceVCConn $sourceVCConn -destVCConn $destVCConn -VM $VM 

                    # Get VM's source network

                    Write-Verbose -Message "[$vmname] Get source Network Adapter."
                    $NetworkAdapter = Get-NetworkAdapter -VM $VM -Server $sourceVCConn

                    # Select VM's destination network

                    Write-Verbose -Message "[$vmname] Select destination portgroups."
                    $PortGroups += Get-DestinationNetwork -Cfg $Cfg -sourceVCConn $sourceVCConn -destVCConn $destVCConn -VM $VM -NetworkAdapters $NetworkAdapter

                    # Execute Move-VM

                    Write-Verbose -Message "[$vmname] Start Move-VM."
                    if ($pscmdlet.ShouldProcess("$vmname", "Start vMotion")) {
                        Move-VM -VM $vm -Destination $Destination -NetworkAdapter $NetworkAdapter -PortGroup $PortGroups -Datastore $Datastore -ErrorAction Continue
                    }
                } else {
                    Write-Verbose -Message "[$vmname] Can't gather Select VM $($VM.Name). Skip it..."
                }
            } else {
                Write-Verbose -Message "[$vmname] Is present in the exclusion list. Skip it..."
            }
        } #End Foreach ($vmname in $VMList.Name)
    } #End Process
} #End Function