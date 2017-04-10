properties {
    # Importing config file
    . $Config
}

task default -depends Connection, Test, Disconnection  

task Connection {
    # Check for already open session to desired source vCenter server
    If ($cfg.sourcevc.vc -notin $global:DefaultVIServers.Name) {
        Try {
            # Attempt connection to vCenter, prompting for credentials
            Write-Verbose "No active connection found to configured vCenter '$($cfg.sourcevc.vc)'. Connecting"
            Connect-VIServer -Server $cfg.sourcevc.vc -user $cfg.sourcevc.user -password $cfg.sourcevc.password -ErrorAction Stop
        } Catch {
            # If unable to connect, stop
            Write-Error -Message 'Error while connecting to the source vCenter. Build cannot continue!' 
        }
    } else {
        Write-Verbose "Already connected to '$($cfg.sourcevc.vc)'"
    }

    # Check for already open session to desired destination vCenter server
    If ($cfg.destinationvc.vc -notin $global:DefaultVIServers.Name) {
        Try {
            # Attempt connection to vCenter, prompting for credentials
            Write-Verbose "No active connection found to configured vCenter '$($cfg.destinationvc.vc)'. Connecting"
            Connect-VIServer -Server $cfg.destinationvc.vc -user $cfg.destinationvc.user -password $cfg.destinationvc.password
        } Catch {
            # If unable to connect, stop
            Write-Error -Message 'Error while connecting to the destination vCenter. Build cannot continue!' 
        }
    } else {
        Write-Verbose "Already connected to '$($cfg.destinationvc.vc)'"
    }
}

task Test -depends Connection {

    $sourceVCConn = $global:DefaultVIServers | Where-Object {$_.Name -match $cfg.sourcevc.vc} | Select-Object -Last 1
    $destVCConn = $global:DefaultVIServers | Where-Object {$_.Name -match $cfg.destinationvc.vc} | Select-Object -Last 1

    $testResults =  Invoke-Pester -PassThru -Script @{
                        Path = $Test
                        Parameters = @{
                            Cfg          = $cfg
                            sourceVCConn = $sourceVCConn
                            destVCConn   = $destVCConn
                        }
                    } # Invoke-Pester
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Migrate -depends Connection, Test {

    $sourceVCConn = $global:DefaultVIServers | Where-Object {$_.Name -match $cfg.sourcevc.vc} | Select-Object -Last 1
    $destVCConn = $global:DefaultVIServers | Where-Object {$_.Name -match $cfg.destinationvc.vc} | Select-Object -Last 1

    Write-Verbose -Message "Get list of VM from scope"
    $VMList = Get-Cluster $cfg.cluster.source -Server $sourceVCConn | Get-VM $cfg.scope.vm -Server $sourceVCConn

    Write-Verbose -Message "Execute function Move-xvCenterVM"
    Try {
         Move-xVCvMotion -Cfg $cfg -sourceVCConn $sourceVCConn -destVCConn $destVCConn -VMList $VMList -Verbose:$VerbosePreference
    }
    Catch {
        write-Error -Message "Build failed! $_"
    }
}

task Disconnection -depends Connection {
    Try {
        Write-Verbose -Message "Disconnection from vCenters $($cfg.sourcevc.vc),$($cfg.destinationvc.vc)"
        Disconnect-VIServer $cfg.sourcevc.vc,$cfg.destinationvc.vc -Confirm:$false
    }
    Catch {
        Write-Error -Message 'Error while disconnecting from vCenter'
    }
    
}

task All -depends Connection, Test, Migrate, Disconnection {
    return $True
}
