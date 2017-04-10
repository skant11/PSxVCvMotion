<#
    .NOTES
    https://github.com/equelin/vmware-powercli-workflows
#>

Function Get-VMPortgroup {
    [CmdletBinding()]
    Param  (
        # Name of the portgroup
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        # vCenter connexion object
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $Server
    )

    Process {

        $VirtualPortGroup = Get-VirtualPortGroup -Name $Name -Server $Server

        Switch -wildcard ($VirtualPortGroup.ExtensionData.Key) { 
            "dvportgroup-*" {Get-VDPortGroup -Name $Name -Server $Server}
            "default" {$VirtualPortGroup}
        } # End Switch   
    } # End Process
} # End Function