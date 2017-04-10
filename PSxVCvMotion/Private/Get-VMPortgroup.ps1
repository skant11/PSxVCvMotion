Function Get-VMPortgroup {
    [CmdletBinding()]
    Param  (
        # Name of the portgroup
        [String]$Name,

        # vCenter connexion object
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