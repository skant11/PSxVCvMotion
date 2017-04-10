[CmdletBinding()]
Param(
    # The $cfg hashtable from a single config file
    [object]$Cfg,
    $sourceVCConn,
    $destVCConn
)

$VM = Get-VM $cfg.scope.vm -Server $sourceVCConn -erroraction SilentlyContinue | Where-Object {$cfg.vm.exclusion -notcontains $_.Name}

Describe -Name 'Testing vSphere Infrastructure' {
    Context -Name 'vCenter versions xVCvMotion compatibility' {
        It -Name "Source and destination vCenter version are compatible with xvCenter vMotion (minimum 6.0)" {
            ($sourceVCConn.Version -ge [version]'6.0') -and ($destVCConn.Version -ge [version]'6.0') | Should Be $True
        }

        If ($sourceVCConn.Version -eq [version]'6.5') {
            It -Name "If source version 6.5, destination version should not be 6.0" {
                ($destVCConn.Version -eq [version]'6.5') | Should Be $false
            }
        }
    }

    Context -Name 'Testing Clusters translation table' {
        foreach ($cluster in $cfg.cluster) {
            It "Source cluster $($cluster.source) exists" {
                {Get-Cluster -Name $cluster.source -Server $sourceVCConn} | Should Not Throw
            }
            It "Destination cluster $($cluster.destination) exists" {
                {Get-Cluster -Name $cluster.destination -Server $destVCConn} | Should Not Throw
            }
        }
    }

    Context -Name 'Testing VMHosts' {

        $sourceVMHosts = @()

        foreach ($cluster in $cfg.cluster) {
            $sourceVMHosts += Get-Cluster -Name $cluster.source -Server $sourceVCConn -ErrorAction SilentlyContinue | Get-VMHost -ErrorAction SilentlyContinue
        }

        $destinationVMHosts = @()

        foreach ($cluster in $cfg.cluster) {
            $destinationVMHosts += Get-Cluster -Name $cluster.destination -Server $destVCConn -ErrorAction SilentlyContinue | Get-VMHost -ErrorAction SilentlyContinue
        }

        It -Name "Source cluster contains VMhosts" {
            $sourceVMHosts.Count | Should BeGreaterThan 0
        }

        Foreach ($VMHost in $sourceVMHosts) {
            It -Name "Source VMHost $($VMHost.Name) version is compatible with xVCvMotion (minimum 6.0)" {
                $VMHost.Version -ge [version]'6.0' | Should Be $True
            }
        }

        It -Name "Destination cluster contains VMhosts" {
            $destinationVMHosts.Count | Should BeGreaterThan 0
        }

        Foreach ($VMHost in $destinationVMHosts) {
            It -Name "Destination VMHost $($VMHost.Name) version is compatible with xVCvMotion (minimum 6.0)" {
                $VMHost.Version -ge [version]'6.0' | Should Be $True
            }
        }
    }

    Context -Name "Testing VMs" {
        It -Name "Found VM matching scope $($cfg.scope.vm)" {
            $VM.count | Should BeGreaterThan 0
        }
    }

    If ($cfg.portgroup) {
        Context -Name 'Testing Portgroups translation table' {
            Foreach ($portgroup in $cfg.portgroup) {

                $sourcePortgroup = Get-VirtualPortGroup -Name $portgroup.source -Server $sourceVCConn -ErrorAction SilentlyContinue

                It -name "Source portgroup $($portgroup.source) exists" {
                    $sourcePortgroup.count | Should BeGreaterThan 0
                }

                $Destinationportgroup = Get-VirtualPortGroup -Name $portgroup.destination -Server $destVCConn -ErrorAction SilentlyContinue

                It -name "Destination portgroup $($portgroup.destination) exists" {
                    $Destinationportgroup.count | Should BeGreaterThan 0
                }

                If ($sourcePortgroup.ExtensionData.Key -like 'dvportgroup-*') {
                    It -name "If source portgroup is a vds, destination can't be a vss" {
                        ($sourcePortgroup.ExtensionData.Key -like 'dvportgroup-*') -and ($Destinationportgroup.ExtensionData.Key -notlike 'dvportgroup-*') | Should Be $False
                    }
                }
            }
        }
    }

    If ($cfg.datastore) {
        Context -Name 'Testing Datastores translation table' {
            Foreach ($datastore in $cfg.datastore) {
                It -name "Source datastore $($datastore.source) exists" {
                    {Get-Datastore -Name $datastore.source -Server $sourceVCConn} | Should Not Throw
                }
                It -name "Destination datastore $($datastore.destination) exists" {
                    {Get-Datastore -Name $datastore.destination -Server $destVCConn} | Should Not Throw
                }
            }
        }
    }
}

